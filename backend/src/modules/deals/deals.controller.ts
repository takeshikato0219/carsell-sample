import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { DealsService } from './deals.service';
import { CreateDealDto, UpdateDealDto } from './dto';
import { Deal, DealStage } from '@/database/entities';

@Controller('deals')
export class DealsController {
  constructor(private readonly dealsService: DealsService) {}

  @Get()
  async findAll(
    @Query('stage') stage?: DealStage,
    @Query('assignedTo') assignedTo?: string,
  ): Promise<Deal[]> {
    return this.dealsService.findAll(stage, assignedTo);
  }

  @Get('kanban')
  async getKanbanBoard(): Promise<{ [key: string]: Deal[] }> {
    return this.dealsService.findByStages();
  }

  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Deal> {
    return this.dealsService.findOne(id);
  }

  @Post()
  async create(@Body() createDealDto: CreateDealDto): Promise<Deal> {
    return this.dealsService.create(createDealDto);
  }

  @Put(':id')
  async update(
    @Param('id') id: string,
    @Body() updateDealDto: UpdateDealDto,
  ): Promise<Deal> {
    return this.dealsService.update(id, updateDealDto);
  }

  @Patch(':id/stage')
  async updateStage(
    @Param('id') id: string,
    @Body('stage') stage: DealStage,
  ): Promise<Deal> {
    return this.dealsService.updateStage(id, stage);
  }

  @Delete(':id')
  async remove(@Param('id') id: string): Promise<void> {
    return this.dealsService.remove(id);
  }
}
