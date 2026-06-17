

class Evolution {
  final int id;
  final int fromId;
  final int toId;
  final String method;

  const Evolution({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.method,


  });


  factory Evolution.fromMap(Map<String, dynamic> map){
    return Evolution(
      id: map['id'] as int,
      fromId: map['from_id'] as int,
      toId: map['to_id'] as int,
      method: map['method'] as String
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'from_id': fromId,
      'to_id': toId,
      'method': method
    };
  }

}