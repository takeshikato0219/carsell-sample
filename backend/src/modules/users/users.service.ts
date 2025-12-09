import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from '@/database/entities';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService implements OnModuleInit {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // アプリケーション起動時にデフォルト管理者を作成
  async onModuleInit() {
    try {
      await this.createDefaultAdmin();
      await this.createDefaultUsers();
    } catch (error) {
      console.log('ℹ️ Default accounts setup skipped (may already exist)');
    }
  }

  private async createDefaultAdmin() {
    const adminEmail = 'admin@katomo.com';
    try {
      const existingAdmin = await this.usersRepository.findOne({ where: { email: adminEmail } });

      if (!existingAdmin) {
        const passwordHash = await bcrypt.hash('admin123', 10);
        await this.usersRepository.save({
          email: adminEmail,
          passwordHash,
          name: '管理者',
          role: UserRole.ADMIN,
          isActive: true,
        });
        console.log('✅ Default admin account created: admin@katomo.com / admin123');
      } else {
        console.log('ℹ️ Admin account already exists');
      }
    } catch {
      console.log('ℹ️ Admin account setup skipped');
    }
  }

  private async createDefaultUsers() {
    // マネージャーアカウント
    const managerEmail = 'manager@katomo.com';
    try {
      const existingManager = await this.usersRepository.findOne({ where: { email: managerEmail } });

      if (!existingManager) {
        const passwordHash = await bcrypt.hash('manager123', 10);
        await this.usersRepository.save({
          email: managerEmail,
          passwordHash,
          name: '目黒',
          role: UserRole.MANAGER,
          isActive: true,
        });
        console.log('✅ Default manager account created: manager@katomo.com / manager123');
      }
    } catch {
      console.log('ℹ️ Manager account setup skipped');
    }

    // 営業アカウント
    const salesEmail = 'sales@katomo.com';
    try {
      const existingSales = await this.usersRepository.findOne({ where: { email: salesEmail } });

      if (!existingSales) {
        const passwordHash = await bcrypt.hash('sales123', 10);
        await this.usersRepository.save({
          email: salesEmail,
          passwordHash,
          name: '野島',
          role: UserRole.SALES,
          isActive: true,
        });
        console.log('✅ Default sales account created: sales@katomo.com / sales123');
      }
    } catch {
      console.log('ℹ️ Sales account setup skipped');
    }
  }

  async findAll(): Promise<User[]> {
    return this.usersRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  async create(userData: Partial<User>, password: string): Promise<User> {
    const passwordHash = await bcrypt.hash(password, 10);
    const user = this.usersRepository.create({
      ...userData,
      passwordHash,
    });
    return this.usersRepository.save(user);
  }

  async update(id: string, userData: Partial<User>): Promise<User> {
    await this.usersRepository.update(id, userData);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.usersRepository.update(id, { isActive: false });
  }

  async validatePassword(user: User, password: string): Promise<boolean> {
    return bcrypt.compare(password, user.passwordHash);
  }
}
