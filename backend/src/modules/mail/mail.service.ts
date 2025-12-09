import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    // Nodemailerのtransporterを設定（汎用SMTP対応）
    const port = parseInt(process.env.SMTP_PORT || '587');

    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: port,
      secure: port === 465, // 465ポートの場合はSSL、それ以外（587等）はTLS
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
      // 追加のセキュリティ設定
      tls: {
        rejectUnauthorized: false, // 自己署名証明書も許可（開発環境用）
      },
    });
  }

  /**
   * 見積書をメールで送信
   */
  async sendEstimateMail(options: {
    to: string;
    estimateNo: string;
    customerName: string;
    salesRepName: string;
    pdfBuffer?: Buffer;
    pdfAttachmentName?: string;
  }): Promise<void> {
    const { to, estimateNo, customerName, salesRepName, pdfBuffer, pdfAttachmentName } = options;

    const mailOptions: nodemailer.SendMailOptions = {
      from: process.env.SMTP_FROM || process.env.SMTP_USER,
      to,
      subject: `【katomotor】お見積書のご送付 - ${estimateNo}`,
      html: `
        <html>
          <body style="font-family: 'Hiragino Sans', 'Hiragino Kaku Gothic ProN', 'Meiryo', sans-serif; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
              <h2 style="color: #2563eb; border-bottom: 2px solid #2563eb; padding-bottom: 10px;">
                お見積書のご送付
              </h2>

              <p>${customerName} 様</p>

              <p>平素より大変お世話になっております。<br>
              株式会社katomotorの${salesRepName}でございます。</p>

              <p>この度は、お問い合わせいただき誠にありがとうございます。<br>
              ご依頼いただきました見積書を添付にてお送りいたします。</p>

              <div style="background-color: #f3f4f6; padding: 15px; border-radius: 8px; margin: 20px 0;">
                <p style="margin: 0; font-weight: bold;">見積番号: ${estimateNo}</p>
              </div>

              <p>ご不明な点やご質問がございましたら、お気軽にお問い合わせください。<br>
              何卒よろしくお願い申し上げます。</p>

              <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">

              <div style="color: #6b7280; font-size: 12px;">
                <p style="margin: 5px 0;"><strong>株式会社katomotor</strong></p>
                <p style="margin: 5px 0;">担当: ${salesRepName}</p>
                <p style="margin: 5px 0;">Email: ${process.env.SMTP_FROM || process.env.SMTP_USER}</p>
              </div>
            </div>
          </body>
        </html>
      `,
    };

    // PDFが提供されている場合は添付
    if (pdfBuffer && pdfAttachmentName) {
      mailOptions.attachments = [
        {
          filename: pdfAttachmentName,
          content: pdfBuffer,
          contentType: 'application/pdf',
        },
      ];
    }

    try {
      await this.transporter.sendMail(mailOptions);
      console.log(`Email sent successfully to ${to}`);
    } catch (error) {
      console.error('Error sending email:', error);
      throw new Error(`メール送信に失敗しました: ${error.message}`);
    }
  }

  /**
   * テストメール送信（設定確認用）
   */
  async sendTestMail(to: string): Promise<void> {
    const mailOptions: nodemailer.SendMailOptions = {
      from: process.env.SMTP_FROM || process.env.SMTP_USER,
      to,
      subject: '【katomotor】メール送信テスト',
      html: `
        <html>
          <body style="font-family: sans-serif;">
            <h2>メール送信テスト</h2>
            <p>このメールは、katomotorシステムからのテスト送信です。</p>
            <p>メール送信機能が正常に動作しています。</p>
          </body>
        </html>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      console.log(`Test email sent successfully to ${to}`);
    } catch (error) {
      console.error('Error sending test email:', error);
      throw new Error(`テストメール送信に失敗しました: ${error.message}`);
    }
  }
}
