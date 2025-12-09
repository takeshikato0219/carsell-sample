import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MailService } from './mail.service';

@Controller('mail')
@UseGuards(JwtAuthGuard)
export class MailController {
  constructor(private readonly mailService: MailService) {}

  @Post('send-estimate')
  async sendEstimate(
    @Body()
    body: {
      to: string;
      estimateNo: string;
      customerName: string;
      salesRepName: string;
      pdfBase64?: string;
      pdfFileName?: string;
    },
  ) {
    const { to, estimateNo, customerName, salesRepName, pdfBase64, pdfFileName } = body;

    // Base64エンコードされたPDFをBufferに変換
    let pdfBuffer: Buffer | undefined;
    if (pdfBase64) {
      pdfBuffer = Buffer.from(pdfBase64, 'base64');
    }

    await this.mailService.sendEstimateMail({
      to,
      estimateNo,
      customerName,
      salesRepName,
      pdfBuffer,
      pdfAttachmentName: pdfFileName || `見積書_${estimateNo}.pdf`,
    });

    return {
      success: true,
      message: 'メールを送信しました',
    };
  }

  @Post('test')
  async sendTest(@Body() body: { to: string }) {
    await this.mailService.sendTestMail(body.to);

    return {
      success: true,
      message: 'テストメールを送信しました',
    };
  }
}
