export interface CategoryResponseDto {
  id: string;
  name: string;
}

export interface ProductVariantResponseDto {
  id: number;
  sku: string;
  price: number;
  attributes: any;
}

export interface Product {
  id: string;
  name: string;
  description: string;
  imageUrl: string; // Match exact avec ton Java
  price: number;
  version: number;
  variants: ProductVariantResponseDto[];
  categories: CategoryResponseDto[];
}

export interface ApiResponse<T> {
  data: T;
  status: number;
}

export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
}