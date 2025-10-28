module AgroAgents
  # OntologyAgent - Agent for managing agricultural technology ontologies
  # Manages base agrotechnologies (БАТ) and adaptive technologies (ААТ)
  # Based on conceptual materials: Yakushev V.V. - ontological structuring of knowledge
  class OntologyAgent < BaseAgroAgent
    def execute_task(task)
      task.start!

      result = case task.task_type
      when 'data_collection'
        collect_ontology_knowledge(task)
      when 'analysis'
        analyze_agrotechnology(task)
      when 'optimization'
        optimize_agrotechnology(task)
      when 'execution'
        execute_agrotechnology(task)
      else
        { status: 'error', message: 'Unknown task type for OntologyAgent' }
      end

      if result[:status] == 'success'
        task.complete!(result)
      else
        task.fail!(result[:message])
      end

      log_execution(task, result)
      result
    rescue => e
      task.fail!(e.message)
      { status: 'error', message: e.message }
    end

    private

    # Collect and structure ontological knowledge
    def collect_ontology_knowledge(task)
      category = task.input_data['category']
      source = task.input_data['source']

      # Collect knowledge entries
      entries_created = 0

      knowledge_items = generate_knowledge_items(category, source)

      knowledge_items.each do |item|
        entry = KnowledgeBaseEntry.create(
          category: item[:category],
          entry_type: item[:entry_type],
          title: item[:title],
          content: item[:content],
          ontology_link: item[:ontology_link],
          related_concepts: item[:related_concepts],
          applicability_conditions: item[:applicability_conditions],
          confidence_level: item[:confidence_level],
          source: source,
          language: 'ru'
        )
        entries_created += 1 if entry.persisted?
      end

      {
        status: 'success',
        message: "Собрано #{entries_created} элементов знаний",
        entries_created: entries_created,
        category: category
      }
    end

    # Analyze agrotechnology for specific conditions
    def analyze_agrotechnology(task)
      crop_type = task.input_data['crop_type']
      soil_type = task.input_data['soil_type']
      climate_zone = task.input_data['climate_zone']

      # Find or create base agrotechnology ontology
      ontology = AgrotechnologyOntology.find_or_create_by(
        crop_type: crop_type,
        soil_type: soil_type,
        climate_zone: climate_zone,
        is_template: true
      ) do |ont|
        ont.name = "БАТ - #{crop_type}"
        ont.description = "Базовая агротехнология для #{crop_type}"
        ont.version = 1
        ont.ontology_data = { created_by: 'OntologyAgent' }
      end

      # Create 11 production cycle operations if not exist
      if ontology.agrotechnology_operations.empty?
        create_production_cycle_operations(ontology)
      end

      {
        status: 'success',
        message: "Проанализирована агротехнология для #{crop_type}",
        ontology_id: ontology.id,
        operations_count: ontology.agrotechnology_operations.count
      }
    end

    # Optimize agrotechnology for specific farm
    def optimize_agrotechnology(task)
      ontology_id = task.input_data['ontology_id']
      farm_id = task.input_data['farm_id']
      crop_id = task.input_data['crop_id']

      ontology = AgrotechnologyOntology.find(ontology_id)
      farm = Farm.find(farm_id)
      crop = crop_id ? Crop.find(crop_id) : nil

      # Analyze farm-specific conditions
      conditions = analyze_farm_conditions(farm)

      # Create adaptive agrotechnology
      adaptations = calculate_adaptations(ontology, conditions)

      adaptive_tech = AdaptiveAgrotechnology.create(
        agrotechnology_ontology: ontology,
        farm: farm,
        crop: crop,
        name: "ААТ - #{ontology.name} для #{farm.name}",
        adaptations: adaptations,
        execution_plan: create_execution_plan(ontology, adaptations),
        status: 'planned'
      )

      # Create zone-specific parameters if zones exist
      if farm.field_zones.any?
        create_zone_parameters(ontology, farm.field_zones, adaptations)
      end

      {
        status: 'success',
        message: "Создана адаптированная агротехнология для #{farm.name}",
        adaptive_tech_id: adaptive_tech.id,
        adaptations_count: adaptations.keys.count
      }
    end

    # Execute agrotechnology operations
    def execute_agrotechnology(task)
      adaptive_tech_id = task.input_data['adaptive_tech_id']
      operation_id = task.input_data['operation_id']

      adaptive_tech = AdaptiveAgrotechnology.find(adaptive_tech_id)
      operation = AgrotechnologyOperation.find(operation_id) if operation_id

      if operation
        # Execute specific operation
        result = execute_operation(adaptive_tech, operation)
      else
        # Activate full technology execution
        adaptive_tech.activate!
        result = { operations: adaptive_tech.operations.count }
      end

      {
        status: 'success',
        message: "Запущено выполнение агротехнологии",
        adaptive_tech_id: adaptive_tech.id,
        execution_result: result
      }
    end

    # Create 11 production cycle operations
    def create_production_cycle_operations(ontology)
      operations_data = [
        {
          name: 'Основная обработка почвы',
          type: :soil_preparation,
          sequence: 1,
          description: 'Вспашка, культивация, боронование',
          parameters: { depth: 25, method: 'plowing' },
          equipment: ['tractor', 'plow', 'cultivator'],
          duration: 3
        },
        {
          name: 'Внесение удобрений',
          type: :fertilization,
          sequence: 2,
          description: 'Внесение основных удобрений',
          parameters: { rate: 120, type: 'NPK' },
          equipment: ['spreader'],
          materials: { 'NPK': 120 },
          duration: 1
        },
        {
          name: 'Подготовка семян',
          type: :seed_preparation,
          sequence: 3,
          description: 'Протравливание, калибровка',
          parameters: { treatment: 'fungicide' },
          materials: { 'fungicide': 2 },
          duration: 1
        },
        {
          name: 'Предпосевная обработка и посев',
          type: :pre_sowing,
          sequence: 4,
          description: 'Культивация и посев',
          parameters: { seed_rate: 180, depth: 5 },
          equipment: ['seeder'],
          materials: { 'seeds': 180 },
          duration: 2
        },
        {
          name: 'Уход за растениями',
          type: :plant_care,
          sequence: 5,
          description: 'Боронование, подкормки',
          parameters: { operations: ['harrowing', 'top_dressing'] },
          equipment: ['harrow', 'spreader'],
          duration: 5
        },
        {
          name: 'Защита растений',
          type: :plant_protection,
          sequence: 6,
          description: 'Обработка от вредителей и болезней',
          parameters: { treatments: 2, type: 'pesticide' },
          equipment: ['sprayer'],
          materials: { 'pesticide': 3 },
          duration: 2
        },
        {
          name: 'Уборка урожая',
          type: :harvesting,
          sequence: 7,
          description: 'Скашивание, обмолот',
          parameters: { method: 'combine' },
          equipment: ['combine_harvester'],
          duration: 5
        },
        {
          name: 'Послеуборочная обработка',
          type: :post_harvest,
          sequence: 8,
          description: 'Очистка, сушка',
          parameters: { moisture_target: 14 },
          equipment: ['cleaner', 'dryer'],
          duration: 3
        },
        {
          name: 'Хранение',
          type: :storage,
          sequence: 9,
          description: 'Размещение на хранение',
          parameters: { temperature: 10, humidity: 70 },
          equipment: ['warehouse'],
          duration: 90
        },
        {
          name: 'Подготовка к реализации',
          type: :preparation_for_sale,
          sequence: 10,
          description: 'Анализ качества, упаковка',
          parameters: { quality_check: true },
          duration: 2
        },
        {
          name: 'Реализация',
          type: :sale,
          sequence: 11,
          description: 'Продажа продукции',
          parameters: { channel: 'wholesale' },
          duration: 5
        }
      ]

      operations_data.each do |op_data|
        ontology.agrotechnology_operations.create(
          name: op_data[:name],
          operation_type: op_data[:type],
          sequence_order: op_data[:sequence],
          description: op_data[:description],
          parameters: op_data[:parameters],
          equipment_requirements: op_data[:equipment],
          material_requirements: op_data[:materials],
          duration_days: op_data[:duration]
        )
      end
    end

    # Analyze farm-specific conditions
    def analyze_farm_conditions(farm)
      conditions = {
        farm_type: farm.farm_type,
        area: farm.area,
        equipment: farm.equipment.available.pluck(:equipment_type),
        zones: farm.field_zones.count
      }

      # Add weather data
      recent_weather = farm.weather_data.recent.first
      if recent_weather
        conditions[:climate] = {
          temperature: recent_weather.temperature,
          precipitation: recent_weather.precipitation
        }
      end

      # Add remote sensing data if available
      if farm.remote_sensing_data.recent.any?
        avg_ndvi = farm.remote_sensing_data.recent.where(data_type: :ndvi).average(:ndvi_value)
        conditions[:field_condition] = { avg_ndvi: avg_ndvi }
      end

      conditions
    end

    # Calculate adaptations based on conditions
    def calculate_adaptations(ontology, conditions)
      adaptations = {
        reasons: [],
        operations: {}
      }

      # Equipment-based adaptations
      available_equipment = conditions[:equipment] || []

      ontology.ordered_operations.each do |operation|
        required = operation.equipment_requirements || []
        missing = required - available_equipment

        if missing.any?
          adaptations[:operations][operation.id] = {
            equipment_substitution: missing.map { |eq| alternative_equipment(eq) }.compact
          }
          adaptations[:reasons] << "Замена техники для #{operation.name}"
        end
      end

      # Zone-based adaptations (precision agriculture)
      if conditions[:zones] > 0
        adaptations[:precision_agriculture] = true
        adaptations[:reasons] << 'Применение дифференцированной технологии по зонам'
      end

      # Climate adaptations
      if conditions.dig(:climate, :precipitation)
        if conditions[:climate][:precipitation] < 10
          adaptations[:irrigation] = true
          adaptations[:reasons] << 'Требуется полив из-за низких осадков'
        end
      end

      adaptations
    end

    # Create execution plan
    def create_execution_plan(ontology, adaptations)
      steps = ontology.ordered_operations.map do |operation|
        {
          id: operation.id,
          operation_id: operation.id,
          name: operation.name,
          type: operation.operation_type,
          sequence: operation.sequence_order,
          duration_days: operation.duration_days,
          start_date: nil, # To be scheduled
          completed: false,
          notes: adaptations.dig(:operations, operation.id)
        }
      end

      {
        steps: steps,
        total_duration: steps.sum { |s| s[:duration_days] || 0 },
        precision_agriculture: adaptations[:precision_agriculture] || false
      }
    end

    # Create zone-specific parameters
    def create_zone_parameters(ontology, zones, adaptations)
      return unless adaptations[:precision_agriculture]

      # For fertilization operation
      fertilization_op = ontology.agrotechnology_operations.find_by(operation_type: :fertilization)

      if fertilization_op
        zones.each do |zone|
          rate = calculate_zone_fertilizer_rate(zone)

          AgrotechnologyParameter.create(
            agrotechnology_operation: fertilization_op,
            field_zone: zone,
            parameter_name: 'nitrogen_rate',
            value: rate,
            unit: 'kg/ha',
            application_method: 'variable_rate',
            justification: {
              ndvi: zone.average_ndvi(30),
              productivity_class: zone.productivity_class,
              reasons: ['Дифференцированное внесение по NDVI']
            }
          )
        end
      end
    end

    # Calculate zone-specific fertilizer rate
    def calculate_zone_fertilizer_rate(zone)
      base_rate = 120 # kg/ha

      case zone.productivity_class
      when 'high'
        base_rate * 1.2
      when 'medium'
        base_rate
      when 'low'
        base_rate * 1.4
      else
        base_rate
      end
    end

    # Execute specific operation
    def execute_operation(adaptive_tech, operation)
      # Mark step as complete in execution plan
      adaptive_tech.complete_step!(operation.id)

      # Check for equipment
      farm = adaptive_tech.farm
      required_equipment = operation.equipment_requirements || []

      available = farm.equipment.available.where(equipment_type: required_equipment)

      {
        operation: operation.name,
        equipment_available: available.count,
        equipment_required: required_equipment.count,
        completed_at: Time.current
      }
    end

    # Find alternative equipment
    def alternative_equipment(equipment_type)
      alternatives = {
        'plow' => 'disk_harrow',
        'seeder' => 'drill_seeder',
        'sprayer' => 'boom_sprayer',
        'combine_harvester' => 'reaper_thresher'
      }

      alternatives[equipment_type]
    end

    # Generate knowledge items for knowledge base
    def generate_knowledge_items(category, source)
      case category
      when 'crop_management'
        [
          {
            category: 'crop_management',
            entry_type: 'best_practice',
            title: 'Оптимальная глубина посева пшеницы',
            content: 'Для яровой пшеницы оптимальная глубина посева 4-6 см в зависимости от типа почвы',
            ontology_link: { uri: 'agro:practice:seed_depth' },
            related_concepts: [],
            applicability_conditions: { crop: 'wheat', season: 'spring' },
            confidence_level: 8
          },
          {
            category: 'crop_management',
            entry_type: 'rule',
            title: 'Норма высева по зонам продуктивности',
            content: 'В зонах высокой продуктивности норму высева увеличивают на 10-15%',
            ontology_link: { uri: 'agro:rule:seeding_rate' },
            related_concepts: [],
            applicability_conditions: { precision_agriculture: true },
            confidence_level: 7
          }
        ]
      when 'soil_health'
        [
          {
            category: 'soil_health',
            entry_type: 'fact',
            title: 'Оптимальный pH для пшеницы',
            content: 'Пшеница предпочитает pH 6.0-7.5',
            ontology_link: { uri: 'agro:fact:ph_wheat' },
            related_concepts: [],
            applicability_conditions: { crop: 'wheat' },
            confidence_level: 9
          }
        ]
      else
        []
      end
    end
  end
end
