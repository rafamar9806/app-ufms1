class CftvInfo {
  int? id;
  String nome;
  String ip;
  String mac;
  String numeroSerie;
  String? imagePath;
  CftvInfo({
    this.id,
    required this.nome,
    required this.ip,
    required this.mac,
    required this.numeroSerie,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'ip': ip,
      'mac': mac,
      'numeroSerie': numeroSerie,
      'imagePath': imagePath,
    };
  }

  factory CftvInfo.fromMap(Map<String, dynamic> map) {
    return CftvInfo(
      id: map['id'],
      nome: map['nome'],
      ip: map['ip'],
      mac: map['mac'],
      numeroSerie: map['numeroSerie'],
      imagePath: map['imagePath'],
    );
  }

  @override
  String toString() {
    return 'CftvInfo{id: $id, nome: $nome, ip: $ip, mac: $mac, numeroSerie: $numeroSerie, imagePath: $imagePath}';
  }
}
