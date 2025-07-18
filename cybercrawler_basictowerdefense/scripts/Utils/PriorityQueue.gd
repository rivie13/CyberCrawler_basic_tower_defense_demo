# PriorityQueue.gd
# Simple min-heap priority queue for A* pathfinding
extends Resource

class_name PriorityQueue

var _heap: Array = []

func size() -> int:
	return _heap.size()

func push(value, priority):
	_heap.append({"value": value, "priority": priority})
	_bubble_up(_heap.size() - 1)

func pop():
	if _heap.size() == 0:
		return null
	var min = _heap[0]["value"]
	_heap[0] = _heap[_heap.size() - 1]
	_heap.pop_back()
	_bubble_down(0)
	return min

func _bubble_up(index):
	while index > 0:
		var parent = int((index - 1) / 2)
		if _heap[index]["priority"] < _heap[parent]["priority"]:
			var temp = _heap[index]
			_heap[index] = _heap[parent]
			_heap[parent] = temp
			index = parent
		else:
			break

func _bubble_down(index):
	var size = _heap.size()
	while true:
		var left = 2 * index + 1
		var right = 2 * index + 2
		var smallest = index
		if left < size and _heap[left]["priority"] < _heap[smallest]["priority"]:
			smallest = left
		if right < size and _heap[right]["priority"] < _heap[smallest]["priority"]:
			smallest = right
		if smallest != index:
			var temp = _heap[index]
			_heap[index] = _heap[smallest]
			_heap[smallest] = temp
			index = smallest
		else:
			break 