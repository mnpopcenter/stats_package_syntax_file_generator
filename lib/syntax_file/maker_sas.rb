# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
  class MakerSAS < Maker

    def initialize(sfc, syntax_type)
      super
      m = @sfc.max_var_name_length
      @var_loc_format = "  %-#{m}s "
      @var_lab_format = "  %-#{m}s %s %s"
      @fmt_link_format = "  %-#{m}s  %s."
      @bignum_int_format = "  %-#{m}s  %d."
      @bignum_dec_format = "  %-#{m}s  %d.%d"
      @cmd_end = ';'
      @label_max_leng = 256
      @segment_max_leng = 100
      @sas_library_handle = 'IPUMS'
      @sas_file_handle = @sfc.is_csv? ? 'CSV' : 'ASCIIDAT'
      @sas_fmt_suffix = '_f'
      @sas_data_file_name = @sas_library_handle + '.' + @sfc.data_file_name_stem
    end

    def supports_csv?
      true
    end

    def syntax
      r = [
        comments_start,
        syn_libname,
        syn_filename,
        blank,
        syn_val_labs,
        syn_df,
        syn_var_labs,
        syn_fmt_link,
        syn_fmt_big_nums,
        syn_run,
        comments_end,
      ]
      r.flatten!
    end

    def comments_start
      convert_to_comments(super)
    end

    def comments_end
      convert_to_comments(super)
    end

    def convert_to_comments(lines)
      return [] if lines.empty?
      [
        '/*',
        lines.map { |ln| '   ' + ln },
        '*/',
        blank,
      ].flatten
    end

    def syn_libname
      'libname ' + @sas_library_handle + ' ' + q(@sfc.data_dir_name) + @cmd_end
    end

    def syn_filename
      'filename ' + @sas_file_handle + ' ' + q(@sfc.data_file_name) + @cmd_end
    end

    def syn_val_labs
      var_list = @sfc.get_vars_with_values
      return [] if var_list.empty?
      r = [
        syn_proc_format,
        blank,
        syn_val_labs_for_var_list(var_list),
        syn_run,
      ]
      r.flatten!
    end

    def syn_proc_format
      'proc format cntlout = ' + @sas_data_file_name + @sas_fmt_suffix + @cmd_end
    end

    def syn_val_labs_for_var_list(var_list)
      r = []
      var_list.each do |var|
        r.push syn_val_labs_for_var_start(var)
        r.push syn_val_labs_for_var(var)
        r.push syntax_end
      end
      r.flatten!
    end

    def syn_val_labs_for_var_start(var)
      'value' +
        (var.is_string_var ? ' $ ' : ' ') +
        var.name +
        @sas_fmt_suffix
    end

    def syn_val_labs_for_var(var)
      val_list = labelable_values(var)
      return [] if val_list.empty?
      m = max_value_length(var, val_list)
      m = m + 2 if var.is_string_var
      m = @segment_max_leng + 2 if m > @segment_max_leng + 2
      fmt = "  %-#{m}s %s %s"
      r = val_list.collect { |val| syn_val_lab_for_val(var, val, fmt) }
      r.flatten!
    end

    def syn_val_lab_for_val(var, val, fmt)
      lab = label_trunc(val.label, @label_max_leng)
      lab = val.value if lab.nil? || (lab.strip.length == 0)
      vs = val_as_s(var, val.value)
      val_segments = label_segments(vs, @segment_max_leng).map { |s| val_q(var, s) }
      lab_segments = label_segments(lab, @segment_max_leng).map { |s| q(s) }
      weave_label_segments(fmt, val_segments, lab_segments, '=', ' ')
    end

    def syn_run
      ['run' + @cmd_end, blank]
    end

    def syn_df
      r = [
        syn_df_start,
        syn_df_infile,
        blank,
        @sfc.data_structure == 'hier' ? syn_dfh : syn_dfr,
      ]
      r.flatten!
    end

    def syn_df_start
      'data ' + @sas_data_file_name + @cmd_end
    end

    def syn_df_infile
      if @sfc.is_csv?
        'infile ' + @sas_file_handle + " missover dsd delimiter=" + q(',') + " firstobs=2" + @cmd_end
      else
        # The LRECL specification is needed because the default behavior on some
        # operating systems is to truncate records to 256 columns.
        c = @sfc.last_column_used
        'infile ' + @sas_file_handle + ' pad missover lrecl=' + c.to_s + @cmd_end
      end
    end

    def syn_dfr
      r = syn_input(@sfc.variables)
      r.push blank
      r
    end

    def syn_input(var_list)
      r = [
        'input',
        syn_var_locations(var_list),
        @cmd_end,
      ]
      r.flatten!
    end

    def syn_var_locations(var_list)
      var_list.collect { |v|
        sprintf(@var_loc_format, v.name) +
          (v.is_string_var ? '$ ' : '  ') +
          (@sfc.is_csv? ? '' : v.column_locations_as_s) +
          implied_decimal_fmt(v)
      }
    end

    def syn_dfh
      r = [
        syn_dfh_retain,
        syn_dfh_rec_type_block,
        blank,
        syn_dfh_if_blocks,
      ]
      r.flatten!
    end

    def syn_dfh_retain
      return [] unless @sfc.rectangularize
      var_list = non_last_non_common_vars
      return [] if var_list.size == 0
      r = [
        'retain',
        var_list.map { |var| '  ' + var.name },
        syntax_end,
      ]
      r.flatten!
    end

    def syn_dfh_rec_type_block
      r = syn_input([@sfc.record_type_var])
      r[1] = r[1] + ' @'
      r
    end

    def syn_dfh_if_blocks
      if_cmd = 'if'
      r = []
      @sfc.record_types.each do |rt|
        r.push(
          syn_dfh_if_start(if_cmd, rt),
          syn_input(@sfc.get_vars_by_record_type(rt)),
          syn_dfh_if_end(rt)
        )
        if_cmd = 'else if'
      end
      r.flatten!
    end

    def syn_dfh_if_start(if_cmd, rt)
      rt_var = @sfc.record_type_var
      r = [
        if_cmd,
        @sfc.record_type_var.name,
        '=',
        val_q(rt_var, val_as_s(rt_var, rt)),
        'then do' + @cmd_end,
      ]
      r.join(' ')
    end

    def syn_dfh_if_end(rt)
      r = []
      r.push 'output' + @cmd_end if (not @sfc.rectangularize) or @sfc.is_last_record_type(rt)
      r.push 'end' + @cmd_end
      r.push blank
      r
    end

    def syn_var_labs
      var_list = @sfc.get_vars_with_var_labels
      return [] if var_list.empty?
      r = [
        'label',
        var_list.map { |var| syn_var_lab_for_var(var) },
        syntax_end,
      ]
      r.flatten!
    end

    def syn_var_lab_for_var(var)
      lab = label_trunc(var.label, @label_max_leng)
      lab_segments = label_segments(lab, @segment_max_leng).map { |s| q(s) }
      weave_label_segments(@var_lab_format, [var.name], lab_segments, '=', ' ')
    end

    def syn_fmt_big_nums
      big_num_vars = @sfc.get_big_nums
      return [] if big_num_vars.empty? || @sfc.is_csv?
      r = [
        'format',
        syn_fmt_big_nums_for_var_list(big_num_vars),
        syntax_end,
      ]
      r.flatten!
    end

    def syn_fmt_big_nums_for_var_list(var_list)
      var_list.map do |v|
        if v.implied_decimals > 0
          sprintf @bignum_dec_format, v.name, v.width + 1, v.implied_decimals
        else
          sprintf @bignum_int_format, v.name, v.width
        end
      end
    end

    def syn_fmt_link
      var_list = @sfc.get_vars_with_values
      return [] if var_list.empty? || @sfc.is_csv?
      r = [
        'format',
        syn_fmt_link_for_var_list(var_list),
        syntax_end,
      ]
      r.flatten!
    end

    def syn_fmt_link_for_var_list(var_list)
      var_list.map { |v|
        sprintf @fmt_link_format, v.name, v.name + @sas_fmt_suffix
      }
    end

    def implied_decimal_fmt(var)
      return '' if var.is_string_var or var.implied_decimals == 0 or @sfc.is_csv?
      return ' .' + var.implied_decimals.to_s
    end

    def non_last_non_common_vars
      # Returns a list of variables, excluding:
      #    - variables from the last record type
      #    - common variables
      var_list = @sfc.rec_types_except_last.map do |rt|
        vars = @sfc.get_vars_by_record_type(rt)
        vars.find_all { |var| not var.is_common_var }
      end
      var_list.flatten!
    end

  end
end
