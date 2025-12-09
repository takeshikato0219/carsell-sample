import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { Contact } from './contact.entity';
import { Quote } from './quote.entity';
import { Deal } from './deal.entity';

@Entity('customers')
export class Customer {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'customer_number', unique: true, nullable: true })
  customerNumber: string;

  @Column({ length: 100 })
  name: string;

  @Column({ name: 'name_kana', length: 100, nullable: true })
  nameKana: string;

  @Column({ nullable: true })
  email: string;

  @Column({ length: 20, nullable: true })
  phone: string;

  @Column({ length: 20, nullable: true })
  mobile: string;

  @Column({ name: 'postal_code', length: 10, nullable: true })
  postalCode: string;

  @Column({ type: 'text', nullable: true })
  address: string;

  @Column({ name: 'company_name', length: 200, nullable: true })
  companyName: string;

  @Column({ length: 100, nullable: true })
  department: string;

  @Column({ length: 100, nullable: true })
  position: string;

  @Column({ type: 'date', nullable: true })
  birthdate: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ length: 50, nullable: true })
  source: string;

  @Column({ name: 'assigned_sales_rep_id', nullable: true })
  assignedSalesRepId: string;

  @ManyToOne(() => User, (user) => user.customers)
  @JoinColumn({ name: 'assigned_sales_rep_id' })
  assignedSalesRep: User;

  @Column({ name: 'created_by', nullable: true })
  createdBy: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @OneToMany(() => Contact, (contact) => contact.customer)
  contacts: Contact[];

  @OneToMany(() => Quote, (quote) => quote.customer)
  quotes: Quote[];

  @OneToMany(() => Deal, (deal) => deal.customer)
  deals: Deal[];
}
