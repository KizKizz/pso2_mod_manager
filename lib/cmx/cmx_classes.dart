import 'dart:typed_data';

class CmxModData {
  CmxModData(this.type, this.id, this.i20, this.i24, this.i28, this.i2C, this.costumeSoundId, this.headId, this.i38, this.i3C, this.linkedInnerId, this.i44, this.legLength, this.f4C, this.f50,
      this.f54, this.f58, this.f5C, this.f60, this.i64, this.redMaskMapping, this.greenMaskMapping, this.blueMaskMapping, this.alphaMaskMapping);
  String type;
  String id, i20, i24, i28, i2C, costumeSoundId, headId, i38, i3C, linkedInnerId, i44, legLength, i64, redMaskMapping, greenMaskMapping, blueMaskMapping, alphaMaskMapping;
  String f4C, f50, f54, f58, f5C, f60;

  CmxModData.parseCmxFromMod(List<String> cmxData)
      : this(cmxData[0], cmxData[1], cmxData[2], cmxData[3], cmxData[4], cmxData[5], cmxData[6], cmxData[7], cmxData[8], cmxData[9], cmxData[10], cmxData[11], cmxData[12], cmxData[13], cmxData[14],
            cmxData[15], cmxData[16], cmxData[17], cmxData[18], cmxData[19], cmxData[20], cmxData[21], cmxData[22], cmxData[23]);
}

class CmxBody {
  CmxBody(this.type, this.id, this.i20, this.i24, this.i28, this.i2C, this.costumeSoundId, this.headId, this.i38, this.i3C, this.linkedInnerId, this.i44, this.legLength, this.f4C, this.f50, this.f54,
      this.f58, this.f5C, this.f60, this.i64, this.redMaskMapping, this.greenMaskMapping, this.blueMaskMapping, this.alphaMaskMapping, this.startIndex, this.endIndex);
  String type;
  int id, i20, i24, i28, i2C, costumeSoundId, headId, i38, i3C, linkedInnerId, i44, i64, redMaskMapping, greenMaskMapping, blueMaskMapping, alphaMaskMapping;
  Float32x4 legLength;
  double f4C, f50, f54, f58, f5C, f60;
  int startIndex, endIndex;

  CmxBody.parseFromCostumeDataList(String type, List<int> cmxData, int startIndex, int endIndex)
      : this(
            type,
            cmxData[0],
            cmxData[8],
            cmxData[13],
            cmxData[14],
            cmxData[15],
            cmxData[16],
            cmxData[17],
            cmxData[18],
            cmxData[19],
            cmxData[20],
            cmxData[21],
            Float32x4.splat(cmxData[22].toDouble()),
            cmxData[23].toDouble(),
            cmxData[24].toDouble(),
            cmxData[25].toDouble(),
            cmxData[26].toDouble(),
            cmxData[27].toDouble(),
            cmxData[28].toDouble(),
            cmxData[29],
            cmxData[9],
            cmxData[10],
            cmxData[11],
            cmxData[12],
            startIndex,
            endIndex);
}
