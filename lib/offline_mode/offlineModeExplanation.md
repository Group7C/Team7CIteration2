# Offline Mode Explanation

offline mode lets app function without backend connection [useful for development and testing]

## how it works

- **detection:** internet connectivity provider monitors network status
- **fallback:** when connection lost, app switches to local mock data
- **local data:** preloaded json files with sample projects and tasks
- **seamless experience:** user can still view and interact with app - solving issue we were having during development where group members couldn't get app working with backend/couldnt get backend setup 
- **consistency:** mock data follows same structure as real api data

## data flow

- app tries api connection first
- if connection fails, offline mode activates
- `OfflineModeHandler` loads mock data from json files
- data injected into same providers used by online mode
- ui components should work normally 

## benefits

- **development:** allows testing without running backend server
- **demo:** enables app showcasing without network dependency
- **reliability:** prevents complete app failure when offline
- **testing:** helps testing different scenarios with controlled data

## technical implementation

- uses flutter's asset system for mock data storage
- json structure mirrors backend api responses
- carefully handles required fields and data types
- converts between json and dart objects [same as online mode]
- integrates with provider state management for seamless experience

## limitations

- **read only:** cannot persistently create/edit data in offline mode
- **consistency:** may not perfectly match latest backend schema
- **completeness:** only includes essential mock data, not full dataset
- **synchronisation:** no way to sync offline changes when reconnected

## usage

- call `OfflineModeHandler.loadMockData(context)` when connection fails
- can be triggered manually for development
- automatically activated by connectivity provider when network lost
- included sample data can be modified for different testing scenarios
