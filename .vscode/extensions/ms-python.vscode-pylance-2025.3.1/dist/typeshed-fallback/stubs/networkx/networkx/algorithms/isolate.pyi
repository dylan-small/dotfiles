from networkx.utils.backends import _dispatchable

@_dispatchable
def is_isolate(G, n): ...
@_dispatchable
def isolates(G): ...
@_dispatchable
def number_of_isolates(G): ...
