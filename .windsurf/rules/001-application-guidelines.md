---
trigger: always_on
---

- Flutter application
- Follow best flutter development practices
- clean code
- clean architecture
- api structured 
- supabase connections
- before creating a file, check if it exists already
- make sure to add context when it is common in industry practices for some features
- if you duplicate code to fix or to adapt or anything, remove the old code from the code base.
- never alter or create migrations, only supabase functions, if required.
- new architecture is on core, features, shared.
- do not change information on the old architecture.
- never leave unsued variables behind.
- avoid try catch - make use of more better techniques when possible like either (which we have already)
- stop using withOpacity as it is deprected but withValues.
- core/config will hold our enviroment variables