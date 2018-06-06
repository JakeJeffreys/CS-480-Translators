#include <iostream>
int main() {
double pi;
double r;
double circle_area;
double circle_circum;
double sphere_vol;
double sphere_surf_area;

pi = 3.1415;
r = 8.0;
circle_area = pi * r * r;
circle_circum = pi * 2 * r;
sphere_vol = (4.0 / 3.0) * pi * r * r * r;
sphere_surf_area = 4 * pi * r * r;


std::cout << "pi: " << pi << std::endl;
std::cout << "r: " << r << std::endl;
std::cout << "circle_area: " << circle_area << std::endl;
std::cout << "circle_circum: " << circle_circum << std::endl;
std::cout << "sphere_vol: " << sphere_vol << std::endl;
std::cout << "sphere_surf_area: " << sphere_surf_area << std::endl;
}