#' calcWetMass
#'
#' @param dv : dv[km/s] needed 
#' @param m_dry : dryMass[kg] of spacecraft
#' @param I_sp :  Specific impulse[s]
#'
#' @return m_wet: wetMass[kg] of spacecraft
#' @export
#'
#' @examples
calcWetMass <- function(dv=3.3, m_dry=1000, I_sp=350){
  
  # Tsiolkovsky rocket equation
  g0 = 9.81   # Standard gravity u.m / u.s**2 
  
  m_wet = m_dry * exp(dv*1000.0 / (I_sp * g0))
  m_fuel = m_wet - m_dry
  
  sprintf("m_dry: %f", m_dry)
  sprintf("m_wet: %f", m_wet)
  sprintf("m_fuel: %f", m_fuel)
  return(m_wet)
}
