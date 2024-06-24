module Utils
    class Singleton
        @instance = new
        private_class_method :new
        def self.instance; @instance end
    end
end