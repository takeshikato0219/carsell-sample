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

export enum DealStage {
  INITIAL_CONTACT = 'initial_contact',
  HEARING = 'hearing',
  QUOTE_SENT = 'quote_sent',
  NEGOTIATION = 'negotiation',
  CONTRACT = 'contract',
  AWAITING_DELIVERY = 'awaiting_delivery',
  DELIVERED = 'delivered',
  LOST = 'lost',
}

export enum DealPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent',
}

@Entity('deals')
export class Deal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'customer_id' })
  customerId: string;

  @ManyToOne(() => Customer, (customer) => customer.deals)
  @JoinColumn({ name: 'customer_id' })
  customer: Customer;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: DealStage,
    default: DealStage.INITIAL_CONTACT,
  })
  stage: DealStage;

  @Column({
    type: 'enum',
    enum: DealPriority,
    default: DealPriority.MEDIUM,
  })
  priority: DealPriority;

  @Column({ name: 'estimated_amount', type: 'decimal', precision: 12, scale: 2, nullable: true })
  estimatedAmount: number;

  @Column({ type: 'int', nullable: true })
  probability: number;

  @Column({ name: 'expected_close_date', type: 'date', nullable: true })
  expectedCloseDate: Date;

  @Column({ name: 'lost_reason', type: 'text', nullable: true })
  lostReason: string;

  @Column({ name: 'assigned_to', nullable: true })
  assignedToId: string;

  @ManyToOne(() => User, (user) => user.deals)
  @JoinColumn({ name: 'assigned_to' })
  assignedTo: User;

  @Column({ name: 'created_by', nullable: true })
  createdBy: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @Column({ name: 'closed_at', nullable: true })
  closedAt: Date;
}
