import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// 简单的 PNG 生成器 - 生成带渐变背景和盾牌图标的应用图标
void main() async {
  const size = 1024;
  final pixels = Uint8List(size * size * 4); // RGBA

  // 渐变颜色: #6C63FF -> #5A52E0
  const r1 = 0x6C, g1 = 0x63, b1 = 0xFF;
  const r2 = 0x5A, g2 = 0x52, b2 = 0xE0;

  // 绘制渐变背景
  for (int y = 0; y < size; y++) {
    final t = y / size;
    final r = (r1 + (r2 - r1) * t).round();
    final g = (g1 + (g2 - g1) * t).round();
    final b = (b1 + (b2 - b1) * t).round();
    for (int x = 0; x < size; x++) {
      final idx = (y * size + x) * 4;
      pixels[idx] = r;
      pixels[idx + 1] = g;
      pixels[idx + 2] = b;
      pixels[idx + 3] = 255;
    }
  }

  // 绘制白色盾牌
  _drawShield(pixels, size, 0xFF, 0xFF, 0xFF);

  // 保存主图标
  await _writePng('assets/icon/app_icon.png', pixels, size, size);

  // 生成前景图（透明背景 + 白色盾牌）
  final fgPixels = Uint8List(size * size * 4);
  _drawShield(fgPixels, size, 0xFF, 0xFF, 0xFF);
  await _writePng('assets/icon/app_icon_foreground.png', fgPixels, size, size);

  print('图标已生成');
}

void _drawShield(Uint8List pixels, int size, int r, int g, int b) {
  final cx = size / 2;
  final cy = size / 2;
  final shieldW = size * 0.38;
  final shieldH = size * 0.44;
  final top = cy - shieldH * 0.5;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - cx).abs().toDouble();
      final dy = y - top;

      if (dy < 0 || dy > shieldH) continue;

      final t = dy / shieldH;
      double maxX;
      if (t < 0.5) {
        // 上半部分：矩形，圆角
        maxX = shieldW;
      } else {
        // 下半部分：收窄到底部尖端
        final t2 = (t - 0.5) / 0.5;
        maxX = shieldW * (1.0 - t2 * t2);
      }

      // 平滑边缘
      if (dx <= maxX - 2) {
        final idx = (y * size + x) * 4;
        pixels[idx] = r;
        pixels[idx + 1] = g;
        pixels[idx + 2] = b;
        pixels[idx + 3] = 255;
      } else if (dx <= maxX) {
        final alpha = ((maxX - dx) / 2 * 255).round().clamp(0, 255);
        final idx = (y * size + x) * 4;
        final existingAlpha = pixels[idx + 3];
        if (alpha > existingAlpha) {
          pixels[idx] = r;
          pixels[idx + 1] = g;
          pixels[idx + 2] = b;
          pixels[idx + 3] = alpha;
        }
      }
    }
  }

  // 在盾牌内绘制钥匙孔（紫色/渐变色）
  final holeY = cy - shieldH * 0.05;
  final holeR = size * 0.06;
  // 圆形部分
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - holeY;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist <= holeR) {
        final idx = (y * size + x) * 4;
        // 如果已经有盾牌的白色，用背景色覆盖
        if (pixels[idx + 3] == 255 && pixels[idx] == r) {
          // 使用渐变背景色
          final t = y / size;
          pixels[idx] = (0x6C + (0x5A - 0x6C) * t).round();
          pixels[idx + 1] = (0x63 + (0x52 - 0x63) * t).round();
          pixels[idx + 2] = (0xFF + (0xE0 - 0xFF) * t).round();
          pixels[idx + 3] = 255;
        }
      }

      // 矩形部分（钥匙孔下方的槽）
      final slotTop = holeY + holeR * 0.3;
      final slotBottom = holeY + holeR * 2.5;
      final slotWidth = holeR * 0.45;
      if (y >= slotTop && y <= slotBottom && (x - cx).abs() <= slotWidth) {
        final idx = (y * size + x) * 4;
        if (pixels[idx + 3] == 255 && pixels[idx] == r) {
          final t = y / size;
          pixels[idx] = (0x6C + (0x5A - 0x6C) * t).round();
          pixels[idx + 1] = (0x63 + (0x52 - 0x63) * t).round();
          pixels[idx + 2] = (0xFF + (0xE0 - 0xFF) * t).round();
          pixels[idx + 3] = 255;
        }
      }
    }
  }
}

// 简单的 PNG 编码器
Future<void> _writePng(String path, Uint8List pixels, int width, int height) async {
  final file = File(path);
  await file.parent.create(recursive: true);

  final out = BytesBuilder();

  // PNG Signature
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR
  final ihdr = BytesBuilder();
  _writeUint32(ihdr, width);
  _writeUint32(ihdr, height);
  ihdr.addByte(8); // bit depth
  ihdr.addByte(6); // RGBA
  ihdr.addByte(0); // compression
  ihdr.addByte(0); // filter
  ihdr.addByte(0); // interlace
  _writeChunk(out, 'IHDR', ihdr.toBytes());

  // IDAT - 使用无压缩的 deflate
  final rawData = BytesBuilder();
  for (int y = 0; y < height; y++) {
    rawData.addByte(0); // filter none
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      rawData.add([pixels[idx], pixels[idx + 1], pixels[idx + 2], pixels[idx + 3]]);
    }
  }

  final compressed = _deflateNoCompression(rawData.toBytes());
  _writeChunk(out, 'IDAT', compressed);

  // IEND
  _writeChunk(out, 'IEND', Uint8List(0));

  await file.writeAsBytes(out.toBytes());
}

void _writeChunk(BytesBuilder out, String type, Uint8List data) {
  final typeBytes = type.codeUnits;
  final lengthBytes = BytesBuilder();
  _writeUint32(lengthBytes, data.length);
  out.add(lengthBytes.toBytes());
  out.add(typeBytes);
  out.add(data);

  // CRC32
  final crcData = Uint8List(typeBytes.length + data.length);
  crcData.setRange(0, typeBytes.length, typeBytes);
  crcData.setRange(typeBytes.length, crcData.length, data);
  final crc = _crc32(crcData);
  final crcBytes = BytesBuilder();
  _writeUint32(crcBytes, crc);
  out.add(crcBytes.toBytes());
}

void _writeUint32(BytesBuilder builder, int value) {
  builder.addByte((value >> 24) & 0xFF);
  builder.addByte((value >> 16) & 0xFF);
  builder.addByte((value >> 8) & 0xFF);
  builder.addByte(value & 0xFF);
}

Uint8List _deflateNoCompression(Uint8List input) {
  // zlib header + no-compression deflate blocks
  final out = BytesBuilder();
  out.addByte(0x78); // CMF
  out.addByte(0x01); // FLG

  const maxBlock = 65535;
  int offset = 0;
  while (offset < input.length) {
    final remaining = input.length - offset;
    final blockSize = remaining > maxBlock ? maxBlock : remaining;
    final isLast = (offset + blockSize) >= input.length;

    out.addByte(isLast ? 0x01 : 0x00); // BFINAL + BTYPE=00
    out.addByte(blockSize & 0xFF);
    out.addByte((blockSize >> 8) & 0xFF);
    out.addByte((~blockSize) & 0xFF);
    out.addByte(((~blockSize) >> 8) & 0xFF);
    out.add(input.sublist(offset, offset + blockSize));
    offset += blockSize;
  }

  // Adler32
  final adler = _adler32(input);
  _writeUint32(out, adler);

  return out.toBytes();
}

int _adler32(Uint8List data) {
  int a = 1, b = 0;
  for (int i = 0; i < data.length; i++) {
    a = (a + data[i]) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}

int _crc32(Uint8List data) {
  int crc = 0xFFFFFFFF;
  for (int i = 0; i < data.length; i++) {
    crc ^= data[i];
    for (int j = 0; j < 8; j++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc >>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
