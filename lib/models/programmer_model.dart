class ProgrammerModel {
  int _value = 0;

  int get value => _value;
  String get dec => _value.toString();
  String get hex => _value.toRadixString(16).toUpperCase();
  String get oct => _value.toRadixString(8);
  String get bin => _formatBinary(_value);

  void setValue(int val) {
    _value = val;
  }

  void inputHex(String hexStr) {
    _value = int.tryParse(hexStr, radix: 16) ?? 0;
  }

  void inputDec(String decStr) {
    _value = int.tryParse(decStr) ?? 0;
  }

  void inputBin(String binStr) {
    _value = int.tryParse(binStr.replaceAll(' ', ''), radix: 2) ?? 0;
  }

  void bitwiseAnd(int other) => _value &= other;
  void bitwiseOr(int other) => _value |= other;
  void bitwiseXor(int other) => _value ^= other;
  void bitwiseNot() => _value = ~_value;
  void shiftLeft(int bits) => _value <<= bits;
  void shiftRight(int bits) => _value >>= bits;

  void clear() => _value = 0;

  String _formatBinary(int n) {
    String raw = n.toRadixString(2);
    // 4 tadan ajratib chiroyli ko'rsatish
    int remainder = raw.length % 4;
    if (remainder != 0) {
      raw = '0' * (4 - remainder) + raw;
    }
    List<String> chunks = [];
    for (int i = 0; i < raw.length; i += 4) {
      chunks.add(raw.substring(i, i + 4));
    }
    return chunks.join(' ');
  }
}
