// オプションデータ（options_extracted.jsonから自動生成）
export interface VehicleOption {
  id: string;
  name: string;
  category: string;
  price: number;
  cost: number;
  isStandard: boolean;
}

export const vehicleOptions: VehicleOption[] = [];

// オプションカテゴリ一覧を取得
export function getOptionCategories(): string[] {
  const categories = new Set(vehicleOptions.map(o => o.category));
  return Array.from(categories).sort();
}

// カテゴリ別オプション一覧を取得
export function getOptionsByCategory(category: string): VehicleOption[] {
  return vehicleOptions.filter(o => o.category === category);
}
