//A local implementation of AyStar.Path used for saving the path

class localPath
{
	_prev = null;
	_tile = null;
	_direction = null;
	_cost = null;

	constructor(old_path, new_tile, new_direction, new_cost)
	{
		this._prev = old_path;
		this._tile = new_tile;
		this._direction = new_direction;
		this._cost = new_cost;
	}
}

	/**
	 * Return the tile where this (partial-)path ends.
	 */
	function localPath::GetTile() { return this._tile; }

	/**
	 * Return the direction from which we entered the tile in this (partial-)path.
	 */
	function localPath::GetDirection() { return this._direction; }

	/**
	 * Return an instance of this class leading to the previous node.
	 */
	function localPath::GetParent() { return this._prev; }

	/**
	 * Return the cost of this (partial-)path from the beginning up to this node.
	 */
	function localPath::GetCost() { return this._cost; }
