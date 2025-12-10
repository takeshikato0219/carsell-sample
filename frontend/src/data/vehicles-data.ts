// 車両データ（vehicles_extracted.jsonから自動生成）
export interface Vehicle {
  id: string;
  modelName: string;       // モデル名（グループ化用）
  version: string;         // バージョン
  baseVehicle: string;     // ベース車両
  transmission: string;    // トランスミッション（2WD/4WD）
  displacement: number;    // 排気量
  fuelType: string;        // 燃料タイプ
  basePrice: number;       // ベース価格（販売価格）
  cost?: number;           // 原価（D欄）- 車両管理で設定
  environmentTax: number;  // 環境性能割
  weightTax: number;       // 重量税
  insurance: number;       // 自賠責保険
  seatingCapacity: number; // 乗車定員
  sleepingCapacity: number;// 就寝定員
  category?: string;       // 車両カテゴリ（軽キャンパー、タウンエース、ハイエースなど）
}

// 車両カテゴリ定義
export const vehicleCategories = [
  { id: 'kei', name: '軽キャンパー', keywords: ['エブリイ', 'ｴﾌﾞﾘｲ'] },
  { id: 'townace', name: 'タウンエース', keywords: ['タウンエース', 'ﾀｳﾝｴｰｽ'] },
  { id: 'hiace', name: 'ハイエース', keywords: ['ハイエース', 'ﾊｲｴｰｽ', 'ﾜｲﾄﾞｽｰﾊﾟｰﾛﾝｸﾞ', 'ワイドスーパーロング'] },
  { id: 'used', name: '中古車', keywords: [], isCustom: true },
  { id: 'oneoff', name: 'ワンオフ', keywords: [], isCustom: true },
  { id: 'other', name: 'その他', keywords: [] },
];

// ベース車両またはモデル名からカテゴリを自動判定
export function getVehicleCategory(baseVehicle: string, modelName?: string): string {
  // 「車両お持込」または「改造」が含まれていたら「その他」に分類
  const textToCheck = `${baseVehicle} ${modelName || ''}`;
  if (textToCheck.includes('車両お持込') || textToCheck.includes('改造')) {
    return 'other';
  }

  for (const cat of vehicleCategories) {
    // baseVehicleまたはmodelNameにキーワードが含まれていればマッチ
    const matchesBase = cat.keywords.some(kw => baseVehicle.includes(kw));
    const matchesModel = modelName ? cat.keywords.some(kw => modelName.includes(kw)) : false;
    if (matchesBase || matchesModel) {
      return cat.id;
    }
  }
  return 'other';
}

// カテゴリIDから名前を取得
export function getCategoryName(categoryId: string): string {
  const category = vehicleCategories.find(c => c.id === categoryId);
  return category ? category.name : 'その他';
}

// 車両データ配列（空）
export const vehicles: Vehicle[] = [];

// 車両モデル一覧を取得（ユニークなmodelName）
export function getVehicleModels(): string[] {
  const models = new Set(vehicles.map(v => v.modelName));
  return Array.from(models).sort();
}

// 特定モデルのグレード（バージョン）一覧を取得
export function getVehicleGrades(modelName: string): Vehicle[] {
  return vehicles.filter(v => v.modelName === modelName);
}

// グレード表示名を取得
export function getGradeDisplayName(vehicle: Vehicle): string {
  return vehicle.version || vehicle.modelName;
}
