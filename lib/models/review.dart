class Review {
  final int id;
  final int rating;
  final String comment;
  final String user;

  Review({required this.id, required this.rating, required this.comment, required this.user});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? json['text'] as String? ?? '',
      user: json['user'] ?? json['username'] ?? '',
    );
  }
}
