export interface OrderItemRequest {
  productId: string;
  quantity: number;
  price: number;
}

export interface OrderRequestDto {
  orderItems: OrderItemRequest[];
  paymentMethod: string;
  status: string; // On enverra 'PAID'
}