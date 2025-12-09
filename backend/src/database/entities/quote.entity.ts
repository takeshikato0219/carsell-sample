import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Customer } from './customer.entity';
import { User } from './user.entity';

export enum QuoteStatus {
  DRAFT = 'draft',
  SENT = 'sent',
  APPROVED = 'approved',
  REJECTED = 'rejected',
}

@Entity('quotes')
export class Quote {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'customer_id' })
  customerId: string;

  @ManyToOne(() => Customer, (customer) => customer.quotes)
  @JoinColumn({ name: 'customer_id' })
  customer: Customer;

  @Column({ name: 'quote_number', unique: true })
  quoteNumber: string;

  @Column({ length: 200, nullable: true })
  title: string;

  @Column({ name: 'vehicle_model', length: 100, nullable: true })
  vehicleModel: string;

  @Column({ name: 'vehicle_grade', length: 100, nullable: true })
  vehicleGrade: string;

  @Column({ name: 'vehicle_color', length: 50, nullable: true })
  vehicleColor: string;

  @Column({ name: 'total_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  totalAmount: number;

  @Column({ name: 'discount_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  discountAmount: number;

  @Column({ name: 'final_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  finalAmount: number;

  @Column({ name: 'excel_file_url', type: 'text', nullable: true })
  excelFileUrl: string;

  @Column({ name: 'pdf_file_url', type: 'text', nullable: true })
  pdfFileUrl: string;

  @Column({
    type: 'enum',
    enum: QuoteStatus,
    default: QuoteStatus.DRAFT,
  })
  status: QuoteStatus;

  @Column({ name: 'valid_until', type: 'date', nullable: true })
  validUntil: Date;

  @Column({ name: 'sent_at', nullable: true })
  sentAt: Date;

  @Column({ name: 'approved_at', nullable: true })
  approvedAt: Date;

  @Column({ name: 'created_by', nullable: true })
  createdBy: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
