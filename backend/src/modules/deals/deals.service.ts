import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Deal, DealStage } from '@/database/entities';
import { CreateDealDto, UpdateDealDto } from './dto';

@Injectable()
export class DealsService {
  constructor(
    @InjectRepository(Deal)
    private dealsRepository: Repository<Deal>,
  ) {}

  async findAll(stage?: DealStage, assignedTo?: string): Promise<Deal[]> {
    const where: any = { closedAt: IsNull() };

    if (stage) {
      where.stage = stage;
    }

    if (assignedTo) {
      where.assignedToId = assignedTo;
    }

    return this.dealsRepository.find({
      where,
      relations: ['customer', 'assignedTo'],
      order: { createdAt: 'DESC' },
    });
  }

  async findByStages(): Promise<{ [key: string]: Deal[] }> {
    const deals = await this.dealsRepository.find({
      where: { closedAt: IsNull() },
      relations: ['customer', 'assignedTo'],
      order: { createdAt: 'DESC' },
    });

    const groupedByStage = {};
    Object.values(DealStage).forEach((stage) => {
      groupedByStage[stage] = deals.filter((deal) => deal.stage === stage);
    });

    return groupedByStage;
  }

  async findOne(id: string): Promise<Deal> {
    const deal = await this.dealsRepository.findOne({
      where: { id },
      relations: ['customer', 'assignedTo', 'creator'],
    });

    if (!deal) {
      throw new NotFoundException(`Deal with ID ${id} not found`);
    }

    return deal;
  }

  async create(createDealDto: CreateDealDto): Promise<Deal> {
    const deal = this.dealsRepository.create(createDealDto);
    return this.dealsRepository.save(deal);
  }

  async update(id: string, updateDealDto: UpdateDealDto): Promise<Deal> {
    await this.dealsRepository.update(id, updateDealDto);
    return this.findOne(id);
  }

  async updateStage(id: string, stage: DealStage): Promise<Deal> {
    const updates: any = { stage };

    if (stage === DealStage.DELIVERED || stage === DealStage.LOST) {
      updates.closedAt = new Date();
    }

    await this.dealsRepository.update(id, updates);
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    await this.dealsRepository.delete(id);
  }
}
