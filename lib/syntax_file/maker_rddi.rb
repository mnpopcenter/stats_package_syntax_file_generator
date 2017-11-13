# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
class MakerRDDI < Maker

def initialize (sfc, syntax_type)
    super
end

def syntax
    r = [
        comments_start,
        check_pkg,
        syn_df,
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

def convert_to_comments (lines)
    return [] if lines.empty?
    [
        lines.map { |ln| '# ' + ln },
        blank,
    ].flatten
end

def check_pkg 
    [
        'if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages(\'ipumsr\')")',
        ''
    ]
end

def syn_df
    ddi_file = @sfc.data_file_name.chomp[0...-3] + 'xml'
    [
        'ddi <- read_ipums_ddi(' + q(ddi_file) + ')',
	    'data <- read_ipums_micro(ddi)',
    ]
end

end
end
