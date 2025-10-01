local Node = {}
Node.__index = Node

type self<T> = {
	data: T,
	next: Node<T>,
}
export type Node<T> = typeof(setmetatable({} :: self<T>, Node))

function Node.new<T>(data: T, nextNode: Node<T>?): Node<T>
	local self = {}
	self.data = data and data or error("Fail to create Node! Data stored is nil!")
	self.next = nextNode and nextNode or nil
	return setmetatable(self, Node)
end

function Node:GetData<T>(): T
	return self.data
end
function Node:GetNext<T>(): Node<T>
	return self.next
end
function Node:SetData<T>(data: T)
	self.data = data
end
function Node:SetNext<T>(node: Node<T>)
	self.next = node
end

return Node
