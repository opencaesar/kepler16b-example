#' calcDeltaV
#'
#' @param initOrbit : altitude[km] of circular orbit
#' @param targetOrbit : altitude[km] of circular orbit
#'
#' @return dv
#' @export
#'
#' @examples
calcDeltaV <- function(initOrbit=400, targetOrbit = 35786){
  # Circular Orbit, Haumann transfer
  # Constant
  GM <- 398600.4354360959 # 地球の重力定数, km3/s2
  re <- 6378.1366 # 地球半径 km
  
  # initOrbit <- 400 # km
  # targetOrbit <- 35786 #km
  
  rp <- re + initOrbit  # LEOの軌道半径, km
  ra <- re + targetOrbit # GEOの軌道半径, km
  
  # LEOの軌道速度とGEOの軌道速度
  v_LEO <- sqrt(GM/rp) * sqrt(2*rp/(rp+rp)) # 円軌道なので近点半径・遠点半径共にrp
  v_GEO <- sqrt(GM/ra) * sqrt(2*ra/(ra+ra)) # 円軌道なので近点半径・遠点半径共にra
  
  # ホーマン遷移軌道の速度
  vp = sqrt(GM/rp) * sqrt(2*ra/(rp+ra))
  va = sqrt(GM/ra) * sqrt(2*rp/(rp+ra))
  
  # ΔV計算
  dv1 = vp-v_LEO
  dv2 = v_GEO-va
  
  print(c(dv1, dv2))
  
  dv = dv1 + dv2
  
  return(dv)
}
