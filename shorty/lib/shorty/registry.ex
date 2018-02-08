defprotocol Shorty.Registry do
  def shorten(registry, url)
  def lookup(registry, id)
end
