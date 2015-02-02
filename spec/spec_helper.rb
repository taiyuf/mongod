$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mongod'

def project_root
  File.expand_path('../../', __FILE__)
end
