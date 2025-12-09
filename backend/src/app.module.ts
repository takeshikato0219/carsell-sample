import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CustomersModule } from './modules/customers/customers.module';
import { DealsModule } from './modules/deals/deals.module';
import { MailModule } from './modules/mail/mail.module';

@Module({
  imports: [
    // 環境変数設定
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // データベース接続
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'mysql',
        host: configService.get('DB_HOST') || configService.get('DATABASE_HOST'),
        port: parseInt(configService.get('DB_PORT') || configService.get('DATABASE_PORT') || '3306'),
        username: configService.get('DB_USERNAME') || configService.get('DATABASE_USER'),
        password: configService.get('DB_PASSWORD') || configService.get('DATABASE_PASSWORD'),
        database: configService.get('DB_DATABASE') || configService.get('DATABASE_NAME'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: configService.get('NODE_ENV') === 'development',
        logging: configService.get('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),

    // モジュール
    AuthModule,
    UsersModule,
    CustomersModule,
    DealsModule,
    MailModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
