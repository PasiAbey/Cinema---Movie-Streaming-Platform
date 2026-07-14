import { useEffect, useRef } from "react";

const VIDFAST_ORIGINS = [
  "https://vidfast.pro",
  "https://vidfast.in",
  "https://vidfast.io",
  "https://vidfast.me",
  "https://vidfast.net",
  "https://vidfast.pm",
  "https://vidfast.xyz",
];

const SAVE_INTERVAL_MS = 15_000;
const API_URL = import.meta.env.VITE_API_URL || "";

/**
 * Listens to Vidfast MEDIA_DATA postMessage events and saves progress
 * via the User Microservice instead of direct Firestore calls.
 */
export function useWatchProgress(currentUser, user) {
  const pendingRef = useRef(null);
  const timerRef = useRef(null);

  useEffect(() => {
    const handleMessage = ({ origin, data }) => {
      if (!VIDFAST_ORIGINS.includes(origin) || !data) return;
      if (data.type !== "MEDIA_DATA") return;
      if (!currentUser?.uid) return;

      const mediaData = data.data;
      if (!mediaData) return;

      // The mediaData object from Vidfast looks like: { "m5335": { progress: {...}, ... } }
      // We extract the first key (there's usually only one per player session)
      const keys = Object.keys(mediaData);
      if (!keys.length) return;
      
      const mediaKey = keys[0]; // e.g. "m5335"
      const mediaId = mediaKey.substring(1);
      const mediaType = mediaKey.startsWith('m') ? 'movie' : 'tv';

      pendingRef.current = { 
        mediaId, 
        mediaType, 
        progressData: mediaData[mediaKey] 
      };
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [currentUser?.uid]);

  useEffect(() => {
    if (!currentUser?.uid) return;

    timerRef.current = setInterval(async () => {
      if (!pendingRef.current) return;
      const { mediaId, mediaType, progressData } = pendingRef.current;
      pendingRef.current = null;

      try {
        const token = await user.getIdToken();
        await fetch(`http://${API_URL}/api/user/progress`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
          },
          body: JSON.stringify({ mediaId, mediaType, progressData })
        });
      } catch (e) {
        console.warn("[useWatchProgress] Failed to sync with microservice:", e);
      }
    }, SAVE_INTERVAL_MS);

    return () => clearInterval(timerRef.current);
  }, [currentUser?.uid]);
}

export function getSavedProgress(profile, mediaId, mediaType) {
  if (!profile?.watchProgress) return null;
  const key = mediaType === "movie" ? `m${mediaId}` : `t${mediaId}`;
  const entry = profile.watchProgress[key];
  if (!entry?.progress) return null;
  return entry.progress;
}

export function getContinueWatchingList(profile) {
  if (!profile?.watchProgress) return [];
  return Object.values(profile.watchProgress)
    .filter((item) => {
      const { watched, duration } = item.progress || {};
      if (!watched || !duration) return false;
      const pct = watched / duration;
      return pct > 0.01 && pct < 0.95;
    })
    .sort((a, b) => (b.last_updated || 0) - (a.last_updated || 0))
    .slice(0, 10);
}
