import 'package:flutter/material.dart';

class SolarProduct {
  const SolarProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.useCase,
    required this.description,
    required this.specification,
    required this.price,
    required this.imageUrl,
    required this.icon,
  });

  final String id;
  final String name;
  final String category;
  final String useCase;
  final String description;
  final String specification;
  final int price;
  final String imageUrl;
  final IconData icon;
}

const solarProducts = <SolarProduct>[
  SolarProduct(id: 'p01', name: 'HomeLight Mini', category: 'Lighting', useCase: 'Popular', description: 'Compact solar lighting kit with phone charging.', specification: '20 W panel · 4 LED lamps · USB charging', price: 48500, imageUrl: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=900&q=80', icon: Icons.lightbulb_outline_rounded),
  SolarProduct(id: 'p02', name: 'SunFlow 16” Solar Fan', category: 'Appliances', useCase: 'Popular', description: 'Portable fan with a dedicated panel and long-life battery.', specification: '16-inch fan · 20 W panel · 8-hour battery', price: 89500, imageUrl: 'https://images.unsplash.com/photo-1592833159155-c62df1b65634?auto=format&fit=crop&w=900&q=80', icon: Icons.air_rounded),
  SolarProduct(id: 'p03', name: 'PowerBox 500', category: 'Power Stations', useCase: 'Popular', description: 'Portable backup power for phones, laptops and lighting.', specification: '500 Wh · 600 W output · 5 ports', price: 385000, imageUrl: 'https://images.unsplash.com/photo-1620714223084-8fcacc6dfd8d?auto=format&fit=crop&w=900&q=80', icon: Icons.battery_charging_full_rounded),
  SolarProduct(id: 'p04', name: 'MonoMax 400 W Panel', category: 'Solar Panels', useCase: 'Popular', description: 'High-efficiency monocrystalline panel for everyday systems.', specification: '400 W · 21% efficiency · 25-year output cover', price: 168000, imageUrl: 'https://images.unsplash.com/photo-1508514177221-188b1cf16e9d?auto=format&fit=crop&w=900&q=80', icon: Icons.solar_power_rounded),
  SolarProduct(id: 'p05', name: 'PureWave 2.5 kVA', category: 'Inverters', useCase: 'Popular', description: 'Quiet pure sine-wave inverter for household essentials.', specification: '2.5 kVA · 24 V · smart protection', price: 410000, imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=900&q=80', icon: Icons.electrical_services_rounded),
  SolarProduct(id: 'p06', name: 'LithiumCore 5 kWh', category: 'Batteries', useCase: 'Popular', description: 'Wall-mounted lithium storage for dependable daily use.', specification: '5 kWh · LiFePO₄ · 6,000 cycles', price: 1450000, imageUrl: 'https://images.unsplash.com/photo-1609592424824-14d8b4c3a7a4?auto=format&fit=crop&w=900&q=80', icon: Icons.battery_full_rounded),
  SolarProduct(id: 'h01', name: 'HomeStart 1 kVA Kit', category: 'Complete Kits', useCase: 'Homes', description: 'Entry home system for lights, phones, television and fan.', specification: '1 kVA · 1.2 kWh battery · 400 W solar', price: 620000, imageUrl: 'https://images.unsplash.com/photo-1497440001374-f26997328c1b?auto=format&fit=crop&w=900&q=80', icon: Icons.home_rounded),
  SolarProduct(id: 'h02', name: 'HomePlus 2.5 kVA', category: 'Complete Kits', useCase: 'Homes', description: 'Balanced residential system for everyday appliances.', specification: '2.5 kVA · 2.56 kWh battery · 1.2 kW solar', price: 1350000, imageUrl: 'https://images.unsplash.com/photo-1559302504-64aae6ca6b6d?auto=format&fit=crop&w=900&q=80', icon: Icons.home_work_outlined),
  SolarProduct(id: 'h03', name: 'FamilyMax 5 kVA', category: 'Complete Kits', useCase: 'Homes', description: 'High-capacity home system for refrigerators and pumps.', specification: '5 kVA · 10 kWh battery · 3.2 kW solar', price: 3950000, imageUrl: 'https://images.unsplash.com/photo-1574263867128-a3d5c1b1deae?auto=format&fit=crop&w=900&q=80', icon: Icons.villa_outlined),
  SolarProduct(id: 'h04', name: 'SafeCharge Controller', category: 'Controllers', useCase: 'Homes', description: 'MPPT controller that protects batteries and improves yield.', specification: '60 A MPPT · 12/24/48 V auto-detect', price: 125000, imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=900&q=80', icon: Icons.settings_input_component_rounded),
  SolarProduct(id: 'c01', name: 'BusinessPro 10 kVA', category: 'Complete Kits', useCase: 'Companies', description: 'Three-phase-ready solar backup for offices and workshops.', specification: '10 kVA · 20 kWh storage · 10 kW array', price: 10800000, imageUrl: 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?auto=format&fit=crop&w=900&q=80', icon: Icons.business_rounded),
  SolarProduct(id: 'c02', name: 'Industrial 30 kVA Hybrid', category: 'Inverters', useCase: 'Companies', description: 'Scalable hybrid power platform for commercial operations.', specification: '30 kVA · three phase · remote monitoring', price: 24750000, imageUrl: 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?auto=format&fit=crop&w=900&q=80', icon: Icons.factory_outlined),
  SolarProduct(id: 'c03', name: 'Commercial Rack Battery', category: 'Batteries', useCase: 'Companies', description: 'Modular rack storage for growing commercial demand.', specification: '15 kWh module · LiFePO₄ · parallel ready', price: 4850000, imageUrl: 'https://images.unsplash.com/photo-1558449028-b53a39d100fc?auto=format&fit=crop&w=900&q=80', icon: Icons.battery_saver_rounded),
  SolarProduct(id: 'c04', name: 'Warehouse Solar Array', category: 'Solar Panels', useCase: 'Companies', description: 'High-output panel bundle for large rooftops.', specification: '12 × 550 W panels · mounting rails included', price: 2860000, imageUrl: 'https://images.unsplash.com/photo-1545208942-e1c9c9165242?auto=format&fit=crop&w=900&q=80', icon: Icons.warehouse_outlined),
  SolarProduct(id: 'v01', name: 'VehicleFlex 200 W', category: 'Solar Panels', useCase: 'Cars & Buses', description: 'Slim semi-flexible panel for vehicle roofs.', specification: '200 W · lightweight · weather resistant', price: 145000, imageUrl: 'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=900&q=80', icon: Icons.directions_car_rounded),
  SolarProduct(id: 'v02', name: 'BusCharge 800 W Kit', category: 'Complete Kits', useCase: 'Cars & Buses', description: 'On-board charging system for buses and service vehicles.', specification: '800 W solar · 2 kWh battery · DC protection', price: 985000, imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=900&q=80', icon: Icons.directions_bus_rounded),
  SolarProduct(id: 'v03', name: 'RoadPower 1 kWh', category: 'Batteries', useCase: 'Cars & Buses', description: 'Compact lithium auxiliary battery for mobile power.', specification: '1 kWh · 12 V · Bluetooth monitor', price: 395000, imageUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&w=900&q=80', icon: Icons.ev_station_rounded),
  SolarProduct(id: 'v04', name: 'Travel Inverter 1.2 kW', category: 'Inverters', useCase: 'Cars & Buses', description: 'Vehicle inverter for tools, devices and small appliances.', specification: '1.2 kW · 12 V DC · pure sine wave', price: 185000, imageUrl: 'https://images.unsplash.com/photo-1597404294360-feeeda04612e?auto=format&fit=crop&w=900&q=80', icon: Icons.commute_rounded),
  SolarProduct(id: 's01', name: 'ShopLite 1.5 kVA', category: 'Complete Kits', useCase: 'Shops & Stores', description: 'Reliable power for lighting, POS, fans and phone charging.', specification: '1.5 kVA · 2 kWh battery · 800 W solar', price: 875000, imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=900&q=80', icon: Icons.storefront_rounded),
  SolarProduct(id: 's02', name: 'MarketCool 3.5 kVA', category: 'Complete Kits', useCase: 'Shops & Stores', description: 'Retail system suitable for freezers and refrigeration.', specification: '3.5 kVA · 5 kWh battery · 2 kW solar', price: 2450000, imageUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?auto=format&fit=crop&w=900&q=80', icon: Icons.ac_unit_rounded),
  SolarProduct(id: 's03', name: 'Solar DC Display Lamps', category: 'Lighting', useCase: 'Shops & Stores', description: 'Bright low-voltage lighting set for product displays.', specification: '6 × 12 W lamps · 10 m cable · controller', price: 68000, imageUrl: 'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?auto=format&fit=crop&w=900&q=80', icon: Icons.light_mode_outlined),
  SolarProduct(id: 's04', name: 'Twin-Core Solar Cable', category: 'Cables', useCase: 'Shops & Stores', description: 'UV-resistant copper cable for safe outdoor installation.', specification: '6 mm² · 50 m roll · red/black pair', price: 92000, imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=900&q=80', icon: Icons.cable_rounded),
];

const professionTypes = <String>[
  'Solar Installer', 'Electrician', 'Carpenter', 'Painter', 'Plumber',
  'Welder', 'Bricklayer', 'Tiler', 'Roofer', 'Air-conditioning Technician',
  'Generator Technician', 'CCTV Installer', 'Appliance Repairer',
  'Interior Designer', 'Gardener', 'Auto Electrician', 'Mechanic',
  'Refrigeration Technician', 'POP Ceiling Installer', 'Handyman',
];

const nigeriaLocations = <String>[
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
  'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
  'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi',
  'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo',
  'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara', 'FCT Abuja',
];

const professionalNames = <String>[
  'Amina Bello', 'Chinedu Okafor', 'David Mensah', 'Grace Etim', 'Ibrahim Musa',
  'Kemi Adeyemi', 'Samuel James', 'Fatima Lawal', 'Peter Ekanem', 'Ngozi Obi',
  'Michael Danjuma', 'Blessing Udo', 'Tunde Balogun', 'Maryam Sani',
  'Emeka Nwosu', 'Ruth Abiola', 'Joseph Tamuno', 'Esther Solomon',
  'Kelvin Omoregie', 'Zainab Garba',
];

const professionalImages = <String>[
  'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1621905251918-48416bd8575a?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1531835551805-16d864c8d311?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1581147036324-c1c89c2c8b5c?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1590650153855-d9e808231d41?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1513467535987-fd81bc7d62f8?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1521791136064-7986c2920216?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1551836022-d5d88e9218df?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=700&q=80',
  'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=700&q=80',
];

