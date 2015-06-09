require 'simple_amqp_server'
require 'digest'

class MedusaFixityServer < SimpleAmqpServer::Base

  attr_accessor :content_root

  FIXITY_ALGORITHM_HASH = {'md5' => Digest::MD5, 'sha1' => Digest::SHA1}

  def initialize(args = {})
    super(args)
    self.content_root = self.config.content(:root)
  end

  def handle_file_fixity_request(interaction)
    relative_path = interaction.request_parameter('path')
    self.logger.info "Computing fixity for: #{relative_path}"
    absolute_path = File.join(self.content_root, relative_path)
    unless File.exists?(absolute_path)
      interaction.fail_generic("File not found: #{relative_path}")
      return
    end
    fixities = Hash.new
    find_algorithms(interaction.request_parameter('algorithms')).each do |algorithm|
      fixities[algorithm] = compute_fixity(absolute_path, algorithm)
    end
    self.logger.info "Computed fixities: #{fixities}"
    interaction.succeed(checksums: fixities)
  end

  def find_algorithms(names)
    names ||= []
    algorithms = names.select { |name| FIXITY_ALGORITHM_HASH.has_key?(name) }
    algorithms = ['md5'] if algorithms.empty?
    algorithms
  end

  def compute_fixity(path, algorithm)
    FIXITY_ALGORITHM_HASH[algorithm].send(:file, path).to_s
  end

end
