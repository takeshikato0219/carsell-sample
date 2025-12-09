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

@Entity('contacts')
export class Contact {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'customer_id' })
  customerId: string;

  @ManyToOne(() => Customer, (customer) => customer.contacts)
  @JoinColumn({ name: 'customer_id' })
  customer: Customer;

  @Column({ name: 'contact_type', length: 50 })
  contactType: string;

  @Column({ length: 200, nullable: true })
  subject: string;

  @Column({ type: 'text', nullable: true })
  content: string;

  @Column({ name: 'audio_file_url', type: 'text', nullable: true })
  audioFileUrl: string;

  @Column({ name: 'memo_file_url', type: 'text', nullable: true })
  memoFileUrl: string;

  @Column({ name: 'next_action', type: 'text', nullable: true })
  nextAction: string;

  @Column({ name: 'next_contact_date', type: 'date', nullable: true })
  nextContactDate: Date;

  @Column({ name: 'contacted_at' })
  contactedAt: Date;

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
