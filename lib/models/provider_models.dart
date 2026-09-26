class ProviderSummary {
  final int totalCustomers;
  final int totalDevices;
  final int activeDevices;
  final int lockedDevices;
  final int successfulPayments;

  const ProviderSummary({
    required this.totalCustomers,
    required this.totalDevices,
    required this.activeDevices,
    required this.lockedDevices,
    required this.successfulPayments,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      totalCustomers: json['total_customers'] ?? 0,
      totalDevices: json['total_devices'] ?? 0,
      activeDevices: json['active_devices'] ?? 0,
      lockedDevices: json['locked_devices'] ?? 0,
      successfulPayments: json['successful_payments'] ?? 0,
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class SolarDevice {
  final int id;
  final String deviceCode;
  final int customerId;
  final String deviceName;
  final String status;
  final double remainingCredit;

  const SolarDevice({
    required this.id,
    required this.deviceCode,
    required this.customerId,
    required this.deviceName,
    required this.status,
    required this.remainingCredit,
  });

  factory SolarDevice.fromJson(Map<String, dynamic> json) {
    return SolarDevice(
      id: json['id'],
      deviceCode: json['device_code'],
      customerId: json['customer_id'],
      deviceName: json['device_name'],
      status: json['status'],
      remainingCredit:
          (json['remaining_credit'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PaymentRecord {
  final int id;
  final String reference;
  final int customerId;
  final int deviceId;
  final double amount;
  final String status;
  final bool fulfilled;
  final DateTime? createdAt;

  const PaymentRecord({
    required this.id,
    required this.reference,
    required this.customerId,
    required this.deviceId,
    required this.amount,
    required this.status,
    required this.fulfilled,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      reference: json['reference'],
      customerId: json['customer_id'],
      deviceId: json['device_id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'],
      fulfilled: json['fulfilled'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}