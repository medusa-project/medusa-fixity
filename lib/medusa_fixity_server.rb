require 'simple_queue_server'
require 'medusa_storage'
require 'digest'

class MedusaFixityServer < SimpleQueueServer::Base

  attr_accessor :storage_roots, :default_root

  FIXITY_ALGORITHM_HASH = {'md5' => Digest::MD5, 'sha1' => Digest::SHA1}

  def initialize(args = {})
    super(args)
    self.default_root = Settings.medusa_storage.default_root
    self.storage_roots = MedusaStorage::RootSet.new(Settings.medusa_storage.roots.to_h
  end

  def handle_file_fixity_request(interaction)
    key = interaction.request_parameter('path')
    storage_root = self.storage_roots.at(request_parameter('root') || self.default_root)
    self.logger.info "Computing fixity for: #{key} for root #{storage_root.name}"
    unless storage_root.exist?(key)
      interaction.succeed(checksums: {}, found: false)
      return
    end
    fixities = Hash.new
    find_algorithms(interaction.request_parameter('algorithms')).each do |algorithm|
      fixities[algorithm] = compute_fixity(storage_root, key, algorithm)
    end
    self.logger.info "Computed fixities: #{fixities}"
    interaction.succeed(checksums: fixities, found: true)
  end

  def find_algorithms(names)
    names ||= []
    algorithms = names.select { |name| FIXITY_ALGORITHM_HASH.has_key?(name) }
    algorithms = ['md5'] if algorithms.empty?
    algorithms
  end

  def compute_fixity(storage_root, key, algorithm)
    hasher = FIXITY_ALGORITHM_HASH[algorithm].new
    buffer = ''
    storage_root.with_input_io(key) do |io|
      while io.read(65536, buffer)
        hasher << buffer
      end
    end
    hasher.to_s
  end

end
