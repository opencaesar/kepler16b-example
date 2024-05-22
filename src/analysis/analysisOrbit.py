# get dv value as [m/s] unit total_delta_v.to(u.m / u.s).value
# get dv value as [km/s] unit total_delta_v.to(u.km / u.s).value

# Here is an example
# rocket = hohmanTransfer(orbit_init=400, orbit_target=35786,m_init=1000 * u.kg, I_sp=350 * u.s)
# total_delta_v = rocket.calculate_delta_v()
# rocket.calculate_fuel_mass()
# print(f"Total delta-v: {total_delta_v}")
# print(f"Required fuel mass: {rocket.m_fuel.to(u.kg)}\n final: {rocket.m_final.to(u.kg)}\n init: {rocket.m_init.to(u.kg)}")


from astropy import units as u
from poliastro.bodies import Earth
from poliastro.twobody import Orbit
from poliastro.maneuver import Maneuver
from poliastro.util import norm
import numpy as np

class hohmanTransfer:
 
    def calculate_delta_v(self):
        hohmann_maneuver = Maneuver.hohmann(self.orb1, self.orb2.a)
        total_delta_v = sum(norm(dv) for (_, dv) in hohmann_maneuver.impulses)
        self.total_delta_v = total_delta_v
        return total_delta_v

    def __init__(self, orbit_init, orbit_target):
        self.m_init = 1000.0
        self.m_final = 0.0
        self.m_fuel = 0.0
        self.I_sp = 350
        self.total_delta_v = 0.0
        self.g0 = 9.81 * u.m / u.s**2
        self.orbit_init = orbit_init
        self.orbit_target = orbit_target
        self.orb1 = Orbit.circular(Earth, self.orbit_init * u.km)
        self.orb2 = Orbit.circular(Earth, self.orbit_target * u.km)


    def calculate_final_mass(self, Isp, m_init):
         dimensionless_delta_v = self.total_delta_v.to(u.m / u.s).value
         self.Isp = Isp
         self.m_init = m_init
         self.m_final = self.m_init / np.exp(dimensionless_delta_v / (self.I_sp * self.g0).value)
         self.m_fuel = self.m_init - self.m_final
         
    def calculate_init_mass(self, Isp, m_final):
         dimensionless_delta_v = self.total_delta_v.to(u.m / u.s).value
         self.Isp = Isp
         self.m_final = m_final
         self.m_init = m_final * np.exp(dimensionless_delta_v / (self.I_sp * self.g0).value)
         self.m_fuel = self.m_init - self.m_final

