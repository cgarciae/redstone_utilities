part of redstone.utilities;

class DbObject
{
  @Id() String id;
}

class Ref extends DbObject
{
  String get href => "IMPLEMENTATION MISSING";
}

class MongoService<T extends Ref> extends MongoDbService<T>
{
  MongoService (String collectionName, MongoConnection mongoConnection) : super.fromConnection(mongoConnection, collectionName);

  Future<T> NewGeneric (T obj) async
  {
    await insert (obj);

    return obj;
  }

  Future<T> GetGeneric (String id, [String errorMsg]) async
  {
    T obj = await findOne
    (
        where.id (stringToId(id))
    );

    if (obj == null)
      throw new app.ErrorResponse (400, errorMsg != null ? errorMsg : "$collectionName not found");

    return obj;
  }

  Future UpdateGeneric (String id, T delta) async
  {
    delta.id = null;

    try
    {
      await update
      (
          where.id(stringToId(id)),
          delta,
          override: false
      );
    }
    catch (e, s)
    {
      await mongoDb.update
      (
          collectionName,
          where.id(stringToId(id)),
          getModifierBuilder (delta, mongoDb)
      );
    }
  }

  Future<Ref> DeleteGeneric (String id) async
  {
    await remove (where.id (stringToId (id)));

    return new Ref()
      ..id = id;
  }
}

class MongoConnection implements MongoDb
{
  MongoDb get mongoDb => _mongoDb != null ? _mongoDb : app.request.attributes.dbConn;
  MongoDb _mongoDb;

  MongoConnection () {}

  MongoConnection.fromMongoDb (this._mongoDb);

  @override
  DbCollection collection(String collectionName) => mongoDb.collection(collectionName);

  @override
  decode(data, Type type) => mongoDb.decode(data, type);

  @override
  encode(data) => mongoDb.encode(data);

  @override
  Future<List> find(collection, Type type, [selector]) => mongoDb.find(collection, type, selector);

  @override
  Future findOne(collection, Type type, [selector]) => mongoDb.findOne(collection, type, selector);

  @override
  Db get innerConn => mongoDb.innerConn;

  @override
  Future insert(collection, Object obj) => mongoDb.insert(collection, obj);

  @override
  Future insertAll(collection, List objs) => mongoDb.insertAll(collection, objs);

  @override
  Future remove(collection, selector) => mongoDb.remove(collection, selector);

  @override
  Future save(collection, Object obj) => mongoDb.save(collection, obj);

  @override
  Future update(collection, selector, Object obj, {bool override: true, bool upsert: false, bool multiUpdate: false})
  => mongoDb.update(collection, selector, obj, override: override, upsert: upsert, multiUpdate: multiUpdate);
}