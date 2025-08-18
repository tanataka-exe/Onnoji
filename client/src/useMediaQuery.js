/*
 * 使い方
 * 
 * const isWide   = useMediaQuery("(min-width: 1200px)");
 * const isMid    = useMediaQuery("(min-width: 768px) and (max-width: 1199px)");
 * const isNarrow = useMediaQuery("(max-width: 767px)");
 * 
 * // ここでモードを切り替えてJS処理を走らせる
 * useEffect(() => {
 *   const mode = isWide ? "wide" : isMid ? "mid" : "narrow";
 *   // 例: オーバーレイを閉じる、ページャ初期化、リスト再計算など
 *   // closeOverlays(); resetPager(); measureColumns();
 * }, [isWide, isMid, isNarrow]);
 * 
 */

// useMediaQuery.ts
import { useEffect, useState } from "react";

export default function useMediaQuery(query: string) {
  const [matches, setMatches] = useState(() => window.matchMedia(query).matches);
  useEffect(() => {
    const mql = window.matchMedia(query);
    const onChange = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener("change", onChange);
    return () => mql.removeEventListener("change", onChange);
  }, [query]);
  return matches;
}
