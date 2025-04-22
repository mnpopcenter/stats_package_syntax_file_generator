# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
  class MakerSPSS < Maker

    def initialize(sfc, syntax_type)
      super
      m = @sfc.max_var_name_length
      @var_loc_format = "  %-#{m}s  %s"
      @var_lab_format = "  %-#{m}s  %s %s"
      @cmd_end = '.'
      @var_label_max_leng = 120
      @val_label_max_leng = 120
      @segment_max_leng = 100
    end

    def supports_csv?
      true
    end

    def syntax
      r = [
        comments_start,
        syn_cd,
        blank,
        syn_df,
        syn_var_labs,
        syn_val_labs,
        syn_execute,
        blank,
        comments_end,
      ]
      r.flatten
    end

    def comments_start
      convert_to_comments(super)
    end

    def comments_end
      convert_to_comments(super)
    end

    def convert_to_comments(lines)
      return [] if lines.empty?
      lines.push @cmd_end
      [
        lines.map { |ln| '* ' + ln },
        blank,
      ].flatten
    end

    def syn_cd
      'cd ' + q(@sfc.data_dir_name) + @cmd_end
    end

    def syn_df
      if @sfc.is_csv?
        syn_dfr_csv
      else
        @sfc.data_structure == 'hier' ? syn_dfh : syn_dfr
      end
    end

    def syn_dfr_csv
      r = [
        'GET DATA  /TYPE=TXT',
        '  /FILE=' + q(@sfc.data_file_name),
        '  /ENCODING=\'UTF8\'',
        '  /DELIMITERS=","',
        '  /QUALIFIER=\'"\'',
        '  /ARRANGEMENT=DELIMITED',
        '  /FIRSTCASE=2',
        '  /DATATYPEMIN PERCENTAGE=10.0',
        '  /VARIABLES=',
        syn_vars_csv(@sfc.variables),
        '  /MAP.',
        'execute.'
      ]
      r.flatten
    end

    def syn_vars_csv(var_list)
      var_list.map { |v| sprintf @var_loc_format, v.name, v.is_string_var ? 'A' : 'AUTO' }
    end

    def syn_dfr
      r = [
        syn_dfr_start,
        syn_var_locations(@sfc.variables),
        syntax_end,
      ]
      r.flatten
    end

    def syn_dfr_start
      'data list file = ' + q(@sfc.data_file_name) + ' /'
    end

    def syn_dfh
      r = [
        syn_dfh_file_type,
        syn_dfh_data_blocks,
        'end file type' + @cmd_end,
        blank,
      ]
      r.flatten
    end

    def syn_dfh_file_type
      r = [
        'file type ' + nested_or_mixed(),
        '  /file = ' + q(@sfc.data_file_name),
        '  /record = ' + var_loc_with_fmt(@sfc.record_type_var).to_s,
        syntax_end,
      ]
      r.flatten
    end

    def syn_dfh_data_blocks
      r = @sfc.record_types.map { |rt|
        [
          syn_dfh_data_block_start(rt),
          syn_var_locations(@sfc.get_vars_by_record_type(rt)),
          syntax_end,
        ]
      }
      r.flatten
    end

    def syn_dfh_data_block_start(rt)
      rt_var = @sfc.record_type_var
      [
        'record type ' + val_q(rt_var, val_as_s(rt_var, rt)) + @cmd_end,
        'data list /',
      ]
    end

    def syn_var_locations(var_list)
      var_list.map { |v| sprintf @var_loc_format, v.name, var_loc_with_fmt(v) }
    end

    def syn_var_labs(var_list = [])
      var_list = @sfc.get_vars_with_var_labels if var_list.empty?
      return [] if var_list.empty?
      r = [
        'variable labels',
        var_list.map { |var| syn_var_lab_for_var(var) },
        syntax_end,
      ]
      r.flatten
    end

    def syn_var_lab_for_var(var)
      lab = label_trunc(var.label, @var_label_max_leng)
      lab_segments = label_segments(lab, @segment_max_leng).map { |s| q(s) }
      weave_label_segments(@var_lab_format, [var.name], lab_segments, ' ', '+')
    end

    def syn_val_labs
      var_list = @sfc.get_vars_with_values
      return [] if var_list.empty?
      r = [
        'value labels',
        syn_val_labs_for_var_list(var_list),
        syntax_end,
      ]
      r.flatten
    end

    def syn_val_labs_for_var_list(var_list)
      var_list.map { |var| syn_val_labs_for_var(var) }
    end

    def syn_val_labs_for_var(var)
      val_list = labelable_values(var)
      return [] if val_list.empty?
      m = max_value_length(var, val_list)
      m = m + 2 if var.is_string_var
      m = @segment_max_leng + 2 if m > @segment_max_leng + 2
      value_format = "    %-#{m}s %s %s"
      r = [
        syn_val_labs_for_var_start(var),
        val_list.map { |val| syn_val_lab_for_val(var, val, value_format) },
      ]
      r.flatten
    end

    def syn_val_labs_for_var_start(var)
      '  /' + var.name
    end

    def syn_val_lab_for_val(var, val, fmt)
      lab = label_trunc(val.label, @val_label_max_leng)
      lab = val.value if lab.nil? || (lab.strip.length == 0)
      vs = val_as_s(var, val.value)
      val_segments = label_segments(vs, @segment_max_leng).map { |s| val_q(var, s) }
      lab_segments = label_segments(lab, @segment_max_leng).map { |s| q(s) }
      weave_label_segments(fmt, val_segments, lab_segments, ' ', '+')
    end

    def syn_execute
      'execute' + @cmd_end
    end

    def nested_or_mixed
      @sfc.rectangularize ? 'nested' : 'mixed'
    end

    def var_loc_with_fmt(var)
      var.column_locations_as_s + var_fmt(var)
    end

    def var_fmt(var)
      return ' (a)' if var.is_string_var
      return '' unless var.implied_decimals > 0
      return ' (' + var.implied_decimals.to_s + ')'
    end

  end
end
