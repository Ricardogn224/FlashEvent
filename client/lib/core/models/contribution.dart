class Contribution {
  final int id;
  final int cagnotteId;
  final int participantId;
  final double amount;

  Contribution({
    required this.id,
    required this.cagnotteId,
    required this.participantId,
    required this.amount,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      cagnotteId: json['cagnotte_id'],
      participantId: json['participant_id'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cagnotte_id': cagnotteId,
      'participant_id': participantId,
      'amount': amount,
    };
  }
}
