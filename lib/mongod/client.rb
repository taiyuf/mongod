# coding: utf-8
require 'active_model'
require 'mongo'
require 'mongod/row'
require 'mongod/pagination'

#
#=lib/mongo/client.rb
#
#== 使用方法
#
# @m = Mongod::Client.new
#   or
# @m = Mongod::Client.new(collection: 'hoge',
#                         databaes:   'foo',
#                         host:       127.0.0.1,
#                         port:       27027)
#
module Mongod

  class Client

    include ActiveModel::Model
    include Mongo
    include Mongod::Pagination

    # autoload :Row, 'mongod_row'

    attr_accessor *%i{
      database
      host
      port
      collection
    }

    validate :check_connection

    def initialize(opts={})

      errors = []
      %i{ database collection host port }.each do |f|
        raise "*** Mongod::Client: '#{f}' is required!" unless opts.keys.include? f
      end

      @_db                = nil
      @_connection        = nil
      @_result            = []
      self.collection    = opts[:collection]
      self.database      = opts[:database]
      self.host          = opts[:host]
      self.port          = opts[:port]
      self.per_page      = opts[:per_page] ? opts[:per_page] : 20
      self.current_page  = 1
      self.total_entries = 0

    end

    #===
    #
    # @param  String or nil #=> ['127.0.0.1:27037', ... ]
    # @return Mongo::Connection object
    #
    # Mongo DBに接続するメソッド。newするときに必要な情報が揃っていない場合も考慮して、手動で呼び出していただきたい
    #
    # @example
    #
    # m = Mongod::Client.new( ... )
    # m.connect
    #
    def connect
      # Todo: 複数のhostに接続しに行く処理
      return false unless self.valid?

      @_connection = MongoClient.new(self.host, self.port) if @_connection.nil?
      @_connection
    end

    #===
    #
    # @param  String
    # @return Mongo::DB object
    #
    # Mongo DBに接続した後に、Mongo::DBオブジェクトを返す
    #
    def get_db(db=nil)
      raise "set argumet or self.database!" if db.nil? and self.database.nil?
      self.database = db if db
      @_db = self.connect.db(self.database) if @_db.nil?
      @_db
    end

    #===
    #
    # @param  String
    # @return Mongo::Collection object
    #
    # Mongo DBに接続した後、渡されたコレクション名のコレクションインスタンスを返す
    #
    def get_collection(collection=nil)

      raise "*** Mongod::get_collection: Please set the value of collection" if collection.nil? and self.collection.nil?

      self.collection = collection unless collection.nil?
      self.get_db.collection(self.collection)
    end

    #===
    #
    # @param  nil
    # @return Array
    #
    def each(*args, &block)
      @_result.each(*args, &block)
    end

    ## CRUD
    #
    # Mongo gemを参照
    #
    # https://github.com/mongodb/mongo-ruby-driver
    #
    def create(hash={})
      self.get_collection.insert(hash)
    end

    # def find(query=nil)
    #   self.get_collection.find(query)
    # end

    def where(hash=nil)
      @_result.clear
      self.get_collection.find(hash).each do |r|
        @_result.push(Mongod::Row.new(r))
      end
      self
    end

    def delete
      @_result.each do |r|
        self.get_collection.remove('_id' => r._id)
      end
      self
    end

    ## Pagenation

    #===
    # 
    # def page=(p=nil)

    #   if p.nil?
    #     self.total_pages
    #   else
    #     # limit 持っているかチェック
    #     self.current_page = p.to_i
    #   end
    # end

    # def paginate(hash={})

    #   self.page     = hash[:page]     unless hash[:page].nil?
    #   self.per_page = hash[:per_page] unless hash[:per_page].nil?

    #   query              = hash[:query] ? hash[:query] : {}
    #   self.total_entries = self.get_collection.find(query).count

    #   @_result = @_result.drop(self.per_page * (self.current_page - 1)).first(self.per_page)

    #   div = self.total_entries.divmod(self.per_page)

    #   if div[1] == 0
    #     pages = div[0].to_i
    #   else
    #     pages = div[0].to_i + 1
    #   end

    #   self.total_pages = pages.to_i
    #   self
    # end

    # def count
    #   @_result.count.to_i
    # end

    # def next_page
    #   if self.current_page.to_i == self.total_pages.to_i
    #     nil
    #   else
    #     self.current_page.to_i + 1
    #   end
    # end

    # def previous_page
    #   if self.current_page.to_i == 1
    #     nil
    #   else
    #     self.current_page.to_i - 1
    #   end
    # end

    # def first_page
    #   1.to_i
    # end


    private

    #===
    #
    # Validation method
    #
    def check_connection
      # self.host, self.portが未設定
      errors.add(:host, 'が設定されていません。') if self.host.nil? or self.host == ''
      errors.add(:port, 'が設定されていません。') if self.port.nil? or self.port == ''

      # self.host, self.portの型チェック
      errors.add(:host, 'は文字列である必要があります。') unless self.host.class.to_s == 'String'
      errors.add(:port, 'は数字である必要があります。')   unless self.port.class.to_s == 'Fixnum'

      if self.host.class.to_s == 'String'
        # self.hostsのフォーマットが正しくない場合
        errors.add(:host, 'のフォーマットが正しくありません。') unless check_host_info(self.host)
      end
    end

    def check_host_info(info)
      return false unless info.class.to_s == 'String'
      return true  if /localhost/          =~ info
      return true  if /\d+\.\d+\.\d+\.\d+/ =~ info
      false
    end

    # alias_method :table,     :collection
    alias_method :last_page, :total_pages

  end

end
