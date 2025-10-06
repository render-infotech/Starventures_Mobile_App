import 'dart:convert';

class ApplicationResponse {
  final List<Application> data;
  final Links links;
  final Meta meta;

  ApplicationResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationResponse(
      data: json['data'] != null
          ? List<Application>.from(json['data'].map((x) => Application.fromJson(x)))
          : [],
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class Application {
  final String id;
  final String customerName;
  final String email;
  final String phone;
  final double loanAmount;
  final String loanType;
  final String status;
  final double monthlyIncome;
  final AssignedTo? assignedTo;
  final CreatedBy? createdBy;
  final String? notes;
  final String? aadhaarFileUrl;
  final String? panCardFileUrl;
  final String? payslipFileUrl;
  final String? bankStatementFileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Application({
    required this.id,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.loanAmount,
    required this.loanType,
    required this.status,
    required this.monthlyIncome,
    this.assignedTo,
    this.createdBy,
    this.notes,
    this.aadhaarFileUrl,
    this.panCardFileUrl,
    this.payslipFileUrl,
    this.bankStatementFileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      loanAmount: double.tryParse(json['loan_amount']?.toString() ?? '0') ?? 0.0,
      loanType: json['loan_type'] ?? '',
      status: json['status'] ?? '',
      monthlyIncome: double.tryParse(json['monthly_income']?.toString() ?? '0') ?? 0.0,
      assignedTo: json['assigned_to'] != null ? AssignedTo.fromJson(json['assigned_to']) : null,
      createdBy: json['created_by'] != null ? CreatedBy.fromJson(json['created_by']) : null,
      notes: json['notes'],
      aadhaarFileUrl: json['aadhaar_file_url'],
      panCardFileUrl: json['pan_card_file_url'],
      payslipFileUrl: json['payslip_file_url'],
      bankStatementFileUrl: json['bank_statement_file_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper getter for display name (using customer_name)
  String get displayName => customerName;

  // Helper method to get formatted amount
  String get formattedAmount {
    return '₹${_formatINR(loanAmount.toInt())}';
  }

  // Helper method to get status enum
  ApplicationStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'pending':
        return ApplicationStatus.pending;
      default:
        return ApplicationStatus.processing;
    }
  }

  // Format as Indian currency
  String _formatINR(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write('${rest.substring(rest.length - 2)},');
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.write(rest);
    final commas = buf.toString().split('').reversed.join();
    return '$commas,$last3';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'email': email,
      'phone': phone,
      'loan_amount': loanAmount.toString(),
      'loan_type': loanType,
      'status': status,
      'monthly_income': monthlyIncome.toString(),
      'assigned_to': assignedTo?.toJson(),
      'created_by': createdBy?.toJson(),
      'notes': notes,
      'aadhaar_file_url': aadhaarFileUrl,
      'pan_card_file_url': panCardFileUrl,
      'payslip_file_url': payslipFileUrl,
      'bank_statement_file_url': bankStatementFileUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AssignedTo {
  final int id;
  final String name;

  AssignedTo({
    required this.id,
    required this.name,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class CreatedBy {
  final int id;
  final String name;

  CreatedBy({
    required this.id,
    required this.name,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

enum ApplicationStatus { processing, approved, pending, rejected }
