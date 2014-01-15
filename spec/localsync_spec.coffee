{Store, Backbone, localSync} = window

describe 'localSync', ->
  describe 'standard Backbone.sync methods', ->
    describe 'creating records', ->
      it 'creates records', ->
        {ready, create, model} = {}
        runs ->
          model = new Backbone.Model id: 1
          create = spyOn(Store.prototype, 'create').andReturn $.Deferred().resolve(model)
          localSync 'create', model, {success: (-> ready = true), error: (-> ready = true)}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(create).toHaveBeenCalledWith model

      it 'does not overwrite existing models with fetch(add: true) unless passed merge: true', ->
        {ready, create} = {}
        runs ->
          ready = false
          create = spyOn(Store.prototype, 'find').andReturn $.Deferred().resolve(id: 1)
          create = spyOn(Store.prototype, 'create').andReturn $.Deferred().resolve()
          model = new Backbone.Model id: 1
          localSync 'create', model, {success: (-> ready = true), error: (-> ready = true), add: true}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          ready = false
          expect(create).not.toHaveBeenCalled()
          model = new Backbone.Model id: 1
          localSync 'create', model, {success: (-> ready = true), error: (-> ready = true), add: true, merge: true}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(create).toHaveBeenCalled()

      it 'supports marking a new record dirty', ->
        {ready, create, model, dirty} = {}
        runs ->
          model = new Backbone.Model id: 1
          create = spyOn(Store.prototype, 'create').andReturn $.Deferred().resolve(model)
          dirty = spyOn(Store.prototype, 'dirty').andReturn $.Deferred().resolve(model)
          localSync 'create', model, {success: (-> ready = true), error: (-> ready = true), dirty: true}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(create).toHaveBeenCalledWith model
          expect(dirty).toHaveBeenCalledWith model

    describe 'reading records', ->
      it 'reads models', ->
        {ready, find, model} = {}
        runs ->
          model = new Backbone.Model id: 1
          find = spyOn(Store.prototype, 'find').andReturn $.Deferred().resolve(model)
          localSync 'read', model, {success: (-> ready = true), error: (-> ready = true)}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(find).toHaveBeenCalledWith model

      it 'reads collections', ->
        {ready, findAll} = {}
        runs ->
          findAll = spyOn(Store.prototype, 'findAll').andReturn $.Deferred().resolve()
          localSync 'read', new Backbone.Collection, {success: (-> ready = true), error: (-> ready = true)}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(findAll).toHaveBeenCalled()

    describe 'updating records', ->
      it 'updates records', ->
        {ready, update, model} = {}
        runs ->
          model = new Backbone.Model id: 1
          update = spyOn(Store.prototype, 'update').andReturn $.Deferred().resolve(model)
          localSync 'update', model, {success: (-> ready = true), error: (-> ready = true)}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(update).toHaveBeenCalledWith model

      it 'supports marking an updated record dirty', ->
        {ready, update, model, dirty} = {}
        runs ->
          model = new Backbone.Model id: 1
          update = spyOn(Store.prototype, 'update').andReturn $.Deferred().resolve(model)
          dirty = spyOn(Store.prototype, 'dirty').andReturn $.Deferred().resolve(model)
          localSync 'update', model, {success: (-> ready = true), error: (-> ready = true), dirty: true}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(update).toHaveBeenCalledWith model
          expect(dirty).toHaveBeenCalledWith model

    describe 'deleting records', ->
      it 'deletes records', ->
        {ready, destroy, model} = {}
        runs ->
          model = new Backbone.Model id: 1
          destroy = spyOn(Store.prototype, 'destroy').andReturn $.Deferred().resolve(model)
          localSync 'delete', model, {success: (-> ready = true), error: (-> ready = true)}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(destroy).toHaveBeenCalledWith model

      it 'supports marking a dirty record destroyed', ->
        {ready, destroy, destroyed, model} = {}
        runs ->
          model = new Backbone.Model id: 1
          destroy = spyOn(Store.prototype, 'destroy').andReturn $.Deferred().resolve(model)
          destroyed = spyOn(Store.prototype, 'destroyed').andReturn $.Deferred().resolve(model)
          localSync 'delete', model, {success: (-> ready = true), error: (-> ready = true), dirty: true}
        waitsFor (-> ready), "A callback should have been called", 100
        runs ->
          expect(destroy).toHaveBeenCalledWith model
          expect(destroyed).toHaveBeenCalledWith model

  describe 'extra methods', ->
    it 'clears out all records from the store', ->
      runs ->
        clear = spyOn(Store.prototype, 'clear').andReturn $.Deferred().resolve()
        localSync 'clear', {}, {success: (-> ready = true), error: (-> ready = true)}

    it 'reports whether or not it hasDirtyOrDestroyed', ->
      runs ->
        clear = spyOn(Store.prototype, 'hasDirtyOrDestroyed').andReturn $.Deferred().resolve()
        localSync 'hasDirtyOrDestroyed', {}, {success: (-> ready = true), error: (-> ready = true)}

  describe 'callbacks', ->
    it "sends the models's attributes as the callback response", ->
      {model, response} = {}
      runs ->
        model = new Backbone.Model id: 1
        localSync 'create', model, {success: ((resp) -> response = resp)}
      waitsFor (-> response), "A callback should have been called with a response", 100
      runs ->
        expect(response).toBe model.attributes

    it 'ignores callbacks when the ignoreCallbacks option is set', ->
      {start, callback} = {start: new Date().getTime()}
      runs ->
        callback = jasmine.createSpy 'callback'
        model = new Backbone.Model id: 1
        localSync 'create', model, {success: callback, error: callback, ignoreCallbacks: true}
      waitsFor (-> new Date().getTime() - start > 5), 'Wait 5 ms to give the callback a chance to execute', 100
      runs ->
        start = false
        expect(callback).not.toHaveBeenCalled()
        model = new Backbone.Model id: 1
        localSync 'create', model, {success: callback, error: callback}
      waitsFor (-> callback.wasCalled), 'The callback should have been called', 100

  describe 'model parameter', ->
    beforeEach ->
      spyOn(Store.prototype, 'create').andReturn $.Deferred().resolve()

    it 'should not accept objects / attributes as model', ->
      attributes = {}
      call = -> localSync 'create', attributes, {ignoreCallbacks: true}
      expect(call).toThrow()

    it 'should accept a backbone model as model', ->
      call = -> localSync 'create', new Backbone.Model, {ignoreCallbacks: true}
      expect(call).not.toThrow()

    it 'should accept a backbone collection as model', ->
      call = -> localSync 'create', new Backbone.Collection, {ignoreCallbacks: true}
      expect(call).not.toThrow()

    it 'should accept any object as model on extra method "clear"', ->
      call = -> localSync 'clear', {}, {ignoreCallbacks: true}
      expect(call).not.toThrow()

    it 'should accept any object as model on extra method "hasDirtyOrDestroyed"', ->
      call = -> localSync 'hasDirtyOrDestroyed', {}, {ignoreCallbacks: true}
      expect(call).not.toThrow()
