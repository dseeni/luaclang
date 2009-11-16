
-- define a new vector type:

local def = header_prefix .. [==[

typedef struct { double x, y, z } vec;

// TODO: implement lua_pushvec, lua_tovec, luaL_checkvec, luaL_optvec, lua_isvec...

int lua_vec_tostring(lua_State * L) {
	vec * self = luaL_checkudata(L, 1, "vec");
	lua_pushfstring(L, "vec %p { x=%f y=%f z=%f }\n", self, self->x, self->y, self->z);
	return 1;
}

int lua_vec_gc(lua_State * L) {
	vec * self = luaL_checkudata(L, 1, "vec");
	lua_pushnil(L);
	lua_setmetatable(L, -2);
	return 0;
}

// TODO: field lookup (vec.x etc.): __index / __newindex

int lua_vec_create(lua_State * L) {
	// TODO: this assumes unnamed argument list; if we pass a table instead, we should use __newindex?
	vec * self = lua_newuserdata(L, sizeof(vec));
	self->x = luaL_optnumber(L, 1, 0.);
	self->y = luaL_optnumber(L, 2, 0.);
	self->z = luaL_optnumber(L, 3, 0.);
	luaL_getmetatable(L, "vec");
	lua_setmetatable(L, -2);
	return 1;
}

extern int luaopen_vec(lua_State * L) {
	luaL_newmetatable(L, "vec");
	lua_pushvalue(L, -1);						lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, lua_vec_tostring);		lua_setfield(L, -2, "__tostring");
	lua_pushcfunction(L, lua_vec_gc);			lua_setfield(L, -2, "__gc");
	lua_pop(L, 1);
	
	struct luaL_reg lib[] = {
		{ "new", lua_vec_create },
		{ NULL, NULL }
	};
	luaL_register(L, "vec", lib);
	return 1;
}

]==]

local m = assert(clang.compile(def))
m:optimize()
m:dump()

local ee = clang.ExecutionEngine
local function call(...)
	return ee.call(m, ...)
end

table.insert(package.loaders, function(name)
	local loadername = "luaopen_"..name
	local F = clang.Function(m, loadername)
	if F then return ee.pushluafunction(m, loadername) end
	return "\n\tnot found in clang"
end)

require "vec"
local v = vec.new(10, 20, 30)
print("v:", v)



