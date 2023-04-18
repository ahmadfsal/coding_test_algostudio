class MemeModel {
  final String? id;
  final String? name;
  final String? url;
  final int? width;
  final int? height;
  final int? boxCount;
  final int? captions;

  MemeModel({
    this.id,
    this.name,
    this.url,
    this.width,
    this.height,
    this.boxCount,
    this.captions,
  });

  factory MemeModel.fromJson(Map<String, dynamic> json) {
    return MemeModel(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      width: json['width'],
      height: json['height'],
      boxCount: json['box_count'],
      captions: json['captions'],
    );
  }
}
