const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
const PORT = 5002; // Hardcoded to 5002 to avoid conflict with .env PORT=5001

app.use(cors());
app.use(express.json());

// Initialize Firebase Admin
if (!admin.apps.length) {
    try {
        // Use service account if file exists, otherwise try fallback
        const firebaseKey = process.env.FIREBASE_SERVICE_ACCOUNT;

        if (firebaseKey) {

            admin.initializeApp({
                credential: admin.credential.cert(
                    JSON.parse(firebaseKey)
                ),
                projectId: process.env.VITE_FIREBASE_PROJECT_ID
            });

            console.log(
                "Firebase Admin initialized from Secrets Manager"
            );

        } else {

            console.warn(
                "No Firebase service account secret found"
            );
        }
        


    } catch (error) {
        console.error('Firebase Admin Init Error:', error.message);
    }
}

const db = admin.firestore();

// Middleware to verify Firebase ID Token
const authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    const idToken = authHeader.split('Bearer ')[1];
    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Invalid token' });
    }
};

// --- Favorites Routes ---

app.get('/favorites', authenticate, async (req, res) => {
    try {
        const userDoc = await db.collection('users').doc(req.user.uid).get();
        if (!userDoc.exists) return res.json([]);
        const data = userDoc.data();
        res.json(data.favorites || []);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/favorites', authenticate, async (req, res) => {
    const { mediaItem } = req.body;
    if (!mediaItem || !mediaItem.id) return res.status(400).json({ error: 'Invalid media item' });

    try {
        const userRef = db.collection('users').doc(req.user.uid);
        await userRef.set({
            favorites: admin.firestore.FieldValue.arrayUnion(mediaItem)
        }, { merge: true });
        res.json({ message: 'Added to favorites' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/favorites/:id', authenticate, async (req, res) => {
    const { id } = req.params;
    try {
        const userRef = db.collection('users').doc(req.user.uid);
        const userDoc = await userRef.get();
        if (!userDoc.exists) return res.status(404).json({ error: 'User not found' });

        const favorites = userDoc.data().favorites || [];
        const itemToRemove = favorites.find(f => String(f.id) === String(id));

        if (itemToRemove) {
            await userRef.update({
                favorites: admin.firestore.FieldValue.arrayRemove(itemToRemove)
            });
        }
        res.json({ message: 'Removed from favorites' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- Watch Progress Routes ---

app.post('/progress', authenticate, async (req, res) => {
    const { mediaId, mediaType, progressData } = req.body;
    if (!mediaId || !mediaType || !progressData) return res.status(400).json({ error: 'Missing data' });

    const key = mediaType === 'movie' ? `m${mediaId}` : `t${mediaId}`;
    try {
        const userRef = db.collection('users').doc(req.user.uid);
        await userRef.set({
            watchProgress: {
                [key]: {
                    ...progressData,
                    last_updated: Date.now()
                }
            }
        }, { merge: true });
        res.json({ message: 'Progress saved' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/progress/:type/:id', authenticate, async (req, res) => {
    const { type, id } = req.params;
    const key = type === 'movie' ? `m${id}` : `t${id}`;
    try {
        const userRef = db.collection('users').doc(req.user.uid);
        await userRef.update({
            [`watchProgress.${key}`]: admin.firestore.FieldValue.delete()
        });
        res.json({ message: 'Progress removed' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/profile', authenticate, async (req, res) => {
    const { name, email } = req.body;
    try {
        const userRef = db.collection('users').doc(req.user.uid);
        const userDoc = await userRef.get();
        
        if (userDoc.exists) {
            return res.status(200).json({ message: 'Profile already exists' });
        }

        await userRef.set({
            name,
            email,
            createdAt: new Date().toISOString(),
            favorites: [],
            watchProgress: {}
        });
        
        res.status(201).json({ message: 'Profile created' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/profile', authenticate, async (req, res) => {
    try {
        const userDoc = await db.collection('users').doc(req.user.uid).get();
        if (!userDoc.exists) return res.status(404).json({ error: 'Profile not found' });
        res.json(userDoc.data());
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`User Service running on port ${PORT}`);
});
