//
//  PWCME.h
//
//  Copyright (c) 2013 Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PWCore/PWContainer.h>
#import <PWCore/PWSchema.h>
#import <PWCore/PWSchemaField.h>
#import <PWCore/PWStructure.h>
#import <PWCore/PWPagination.h>

extern NSInteger const kPWCMEDepthFullHierarchy;
extern NSInteger const PWCMSUnused;

/**
 `PWCME` provides a full-featured content management solution that allows you to deliver engaging content to your users.

 */

@interface PWCME : NSObject

///-----------------------
/// @name Container Methods
///-----------------------

/**
 Returns a list of the available containers.
 @param success A block object to be executed when `getAllContainersWithSuccess:failure:` succeeds. This block has no return value and takes one argument: the containers received from the server (an `NSArray` object that contains `PWContainer` objects).
 @param failure A block object to be executed when `getAllContainersWithSuccess:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getAllContainersWithSuccess:(void(^)(NSArray *containers))success failure:(void (^)(NSError *error))failure;

/**
 Returns a `PWContainer` object for the specified Container ID.
 @param containerID The requested Container ID.
 @param success A block object to be executed when `getContainerWithContainerID:success:failure:` succeeds. This block has no return value and takes one argument: the container received from the server.
 @param failure A block object to be executed when `getContainerWithContainerID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getContainerWithContainerID:(NSString *)containerID success:(void(^)(PWContainer *container))success failure:(void (^)(NSError *error))failure;

///-----------------------
/// @name Schema Methods
///-----------------------

/**
 Returns a list of the available `PWSchema` objects.
 @param limit Specifies the number of results to return. This is useful for pagination. Default value is 10 and maximum value is 100.
 @param offset Specifies the number of results to offset. This is useful for pagination. Default value is 0.
 @param success A block object to be executed when `getSchemasWithLimit:limit:offset:success:failure:` succeeds. This block has no return value and takes one argument: the schemas received from the server (an `NSArray` object that contains `PWSchema` objects).
 @param failure A block object to be executed when `getSchemasWithLimit:limit:offset:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getSchemasWithLimit:(NSInteger)limit offset:(NSInteger)offset success:(void(^)(NSArray *schemas, PWPagination *pagination, BOOL pagingEnabled))success failure:(void (^)(NSError *error))failure;

/**
 Returns a `PWSchema` object for the specified Schema ID.
 @param schemaID The requested Schema ID.
 @param success A block object to be executed when `getSchemaWithSchemaID:success:failure:` succeeds. This block has no return value and takes one argument: the schema received from the server.
 @param failure A block object to be executed when `getSchemaWithSchemaID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getSchemaWithSchemaID:(NSString *)schemaID success:(void(^)(PWSchema *schema))success failure:(void (^)(NSError *error))failure;


///-----------------------
/// @name Structure Methods
///-----------------------

/**
 This method is used to get a structure. Depending on the request parameters, this may return a multi-level structure or a single-level structure. Traversal will begin at the root level. Otherwise, traversal will begin at the structure item with the specified id.
 @param containerID The ID of the container to get the structures for.
 @param depth The depth to traverse into child structures. If the depth is set to 0 then no child structures will be returned, if the depth is set to 1 then the immediate child structures will be returned, and so on. To get the full hierarchy of children use `kPWCMEDepthFullHierarchy`. Be careful when using this value for large structures.
 @param schema If `YES` then the schema will be returned for structures that have one.
 @param success A block object to be executed when `getStructureForContainerID:depth:includeSchema:success:failure:` succeeds. This block has no return value and takes one argument: The structure received from the server.
 @param failure A block object to be executed when `getStructureForContainerID:depth:includeSchema:success:failure:` fails. This block has no return value and takes one argument:, an NSError object describing the error that occurred.
 */
+ (void)getStructuresForContainerID:(NSString *)containerID depth:(NSInteger)depth includeSchema:(BOOL)schema success:(void(^)(NSArray *structures))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to get a structure for a specified structure ID. Depending on the request parameters, this may return a multi-level structure, or a single-level structure. Traversal will begin at the root level. Otherwise, traversal will begin at the structure item with the specified ID.
 @param structureID The ID of the structure.
 @param containerID The ID of the container.
 @param depth The depth to traverse into child structures. If the depth is set to 0 (default), then no child structures will be returned; if the depth is set to 1, then the immediate child structures will be returned; and so on. To get the full hierarchy of children, use `kPWCMEDepthFullHierarchy`. Be careful when using this value for large structures.
 @param schema If `YES`, then the schema will be returned for structures that have one.
 @param success A block object to be executed when `getStructureForContainerID:depth:includeSchema:success:failure:` succeeds. This block has no return value and takes one argument: the structure received from the server.
 @param failure A block object to be executed when `getStructureForContainerID:depth:includeSchema:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getStructureWithID:(NSUInteger)structureID containerID:(NSString *)containerID depth:(NSInteger)depth includeSchema:(BOOL)schema success:(void(^)(PWStructure *structure))success failure:(void (^)(NSError *error))failure;

///-----------------------
/// @name Content Methods
///-----------------------

/**
 Gets the content based on the structure hierarchy and schemas. The structure of the response data for this method relies completely on the structure of the structures and schemas. Content will be retrieved starting from the root level.
 @param contentID The Content ID to fetch.
 @param containerID The ID of the container to get the content for.
 @param structureID The ID of the structure item to start at. If no Structure ID is specified, then the content will be retrieved starting from the root level. Otherwise, the content will be retrieved starting at the level in the structure hierarchy that the specified structure item resides.
 @param parentID The ID of the parent content item. This is used to filter to appropriate child content for a specific branch in the content hierarchy.
 @param limit Specifies the number of results to return. This is useful for pagination. Default value is 10 and maximum value is 100. NOTE: This parameter is only used when the structure_id references a structure item of type array.
 @param offset Specifies the number of results to offset. This is useful for pagination. Default value is 0. NOTE: This parameter is only used when the structure_id references a structure item of type array.
 @param success A block object to be executed when `getContentForContainerID:success:failure:` succeeds. This block has no return value and takes one argument: The content received from the server. The structure of the response data for this method relies completely on the structure of the structures and schemas.
 @param failure A block object to be executed when `getContentForContainerID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getContentForContentID:(NSString *)contentID containerID:(NSString *)containerID structureID:(NSInteger)structureID parentID:(NSString *)parentID limit:(NSInteger)limit offset:(NSInteger)offset success:(void(^)(id content))success failure:(void (^)(NSError *error))failure;

/**
 Gets the content for the specified Content ID and Container ID. The structure of the response data for this method relies completely on the structures and schemas.
 @param contentID The Content ID to fetch.
 @param containerID The ID of the container to get the content for.
 @param structureID The ID of the structure item to start at.
 @param success A block object to be executed when `getContentForContentID:containerID:success:failure:` succeeds. This block has no return value and takes one argument: the content received from the server. The structure of the response data for this method relies completely on the structure of the structures and schemas.
 @param failure A block object to be executed when `getContentForContentID:containerID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getContentForContentID:(NSString *)contentID containerID:(NSString *)containerID structureID:(NSInteger)structureID success:(void(^)(id content))success failure:(void (^)(NSError *error))failure;

/**
 Gets all content based on the menu hierarchy and schemas. The structure of the response data for this method relies completely on the structure and schemas.
 @param containerID The ID of the container to get the content for.
 @param depth The depth to traverse into child structures. If the depth is set to 0 then no child structures will be returned, if the depth is set to 1 then the immediate child structures will be returned, and so on. To get the full hierarchy of children use `kPWCMEDepthFullHierarchy`. Be careful when using this value for large structures.
 @param limit The number of contents to be fetched.
 @param offset The offset from where the contents need be fetched.
 @param success A block object to be executed when `getAllContentsForContainerID:limit:offset:success:failure:` succeeds. This block has no return value and takes three arguments: the content received from the server, a `PWPagination` object that details content pagination information and a BOOL value that indicates whether or not paging is enabled. The structure of the content data relies completely on the structure of the structures and schemas.
 @param failure A block object to be executed when `getAllContentsForContainerID:limit:offset:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 @discussion It's important to note that this method only returns the specified pagination parameters for the root level array object. Nested arrays default to a pagination of 10 and a limit of 0.
 */
+ (void)getAllContentsForContainerID:(NSString *)containerID depth:(NSInteger)depth limit:(NSInteger)limit offset:(NSInteger)offset success:(void(^)(id contents, PWPagination *pagination, BOOL pagingEnabled))success failure:(void (^)(NSError *error))failure;

/**
 Gets all content for a specific Container ID and Structure ID. The structure of the content data for this method relies completely on the structure and schemas.
 @param containerID The ID of the container to get the content for.
 @param structureID The ID of the structure to get the content for.
 @param limit Specifies the number of results to return. This is useful for pagination. Default value is 10 and maximum value is 100.
 @param offset Specifies the number of results to offset. This is useful for pagination. Default value is 0.
 @param success A block object to be executed when `getContentsForContainerID:structureID:limit:offset:success:failure:` succeeds. This block has no return value and takes three arguments: the content received from the server, a `PWPagination` object that details content pagination information and a BOOL value that indicates whether or not paging is enabled. The structure of the content data relies completely on the structure of the structures and schemas.
 @param failure A block object to be executed when `getContentsForContainerID:structureID:limit:offset:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getContentsForContainerID:(NSString *)containerID structureID:(NSInteger)structureID limit:(NSInteger)limit offset:(NSInteger)offset success:(void(^)(id contents, PWPagination *pagination, BOOL pagingEnabled))success failure:(void (^)(NSError *error))failure;

/**
 Gets all content for a specific Container ID, Parent ID, and Structure ID. The structure of the content data for this method relies completely on the structure and schemas.
 @param containerID The ID of the container to get the content for.
 @param parentID The ID of the parent content to get the content for.
 @param structureID The ID of the structure to get the content for.
 @param limit Specifies the number of results to return. This is useful for pagination. Default value is 10 and maximum value is 100.
 @param offset Specifies the number of results to offset. This is useful for pagination. Default value is 0.
 @param success A block object to be executed when `getContentsForContainerID:structureID:limit:offset:success:failure:` succeeds. This block has no return value and takes three arguments: the content received from the server, a `PWPagination` object that details content pagination information and a BOOL value that indicates whether or not paging is enabled. The structure of the content data relies completely on the structure of the structures and schemas.
 @param failure A block object to be executed when `getContentsForContainerID:structureID:limit:offset:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)getContentsForContainerID:(NSString *)containerID parentID:(NSString *)parentID structureID:(NSInteger)structureID limit:(NSInteger)limit offset:(NSInteger)offset success:(void(^)(id contents, PWPagination *pagination, BOOL pagingEnabled))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to save new content. If no parent content exists, you should use `addContent:structureID:success:failure:`.
 @param content The content to save.
 @param containerID The ID of the container to add the content to.
 @param structureID The ID of the structure the content is associated to.
 @param parentContentID The ID of the parent content item. This is used to link up any dynamic children of this structure item that may have already been created when the associated structure is itself within a dynamic structure item. When this is the case, the only way to know which child content path is associated with this parent content data is to supply the parent to this content item.
 @param success A block object to be executed when `addContent:structureID:parentContentID:success:failure:` succeeds. This block has no return value and takes no arguments.
 @param failure A block object to be executed when `addContent:structureID:parentContentID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)addContent:(NSDictionary *)content containerID:(NSString *)containerID structureID:(NSUInteger)structureID parentContentID:(NSString *)parentContentID success:(void (^)(NSString *newContentID))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to save new content. If parent content exists, you should use `addContent:structureID:parentContentID:success:failure:`.
 @param content The content to save.
 @param containerID The ID of the container to add the content to.
 @param structureID The ID of the structure the content is associated to.
 @param success A block object to be executed when `addContent:structureID:success:failure:` succeeds. This block has no return value and takes no arguments.
 @param failure A block object to be executed when `addContent:structureID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)addContent:(NSDictionary *)content containerID:(NSString *)containerID structureID:(NSUInteger)structureID success:(void (^)(NSString *newContentID))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to update existing content.
 @param contentID The specified Content ID.
 @param containerID The ID of the container where the content resides.
 @param structureID The specified structure ID.
 @param updatedContent The updated content. If a parameter IS NOT specified, it will retain its current value. If a parameter IS specified with an empty value, then the value will be cleared.
 @param success A block object to be executed when `updateContentForContentID:strucureID:updatedContent:success:failure:` succeeds. This block has no return value and takes no arguments.
 @param failure A block object to be executed when `updateContentForContentID:structureID:updatedContent:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)updateContentForContentID:(NSString *)contentID containerID:(NSString *)containerID structureID:(NSUInteger)structureID updatedContent:(NSDictionary *)updatedContent success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to update existing content.
 @param contentID The specified Content ID.
 @param containerID The ID of the container where the content resides.
 @param structureID The specified structure ID.
 @param updatedContent The updated content. If a parameter IS NOT specified, it will retain its current value. If a parameter IS specified with an empty value, then the value will be cleared.
 @param parentContentID The specified parent Content ID.
 @param success A block object to be executed when `updateContentForContentID:updatedContent:structureID:parentContentID:success:failure:` succeeds. This block has no return value and takes no arguments.
 @param failure A block object to be executed when `updateContentForContentID:updatedContent:structureID:parentContentID:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)updateContentForContentID:(NSString *)contentID containerID:(NSString *)containerID structureID:(NSUInteger)structureID parentContentID:(NSString *)parentContentID updatedContent:(NSDictionary *)updatedContent success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 This method is used to delete a specific content item. If the associated structure for the content is a dynamic object structure residing in a parent array structure, then all child content will be deleted as well. However, if the associated structure for the content is a static structure item, only the specified content will be deleted.
 @param contentID The specified Content ID.
 @param traverse If 'YES', then child content will be deleted as well. This parameter is only useful when the Content ID is associated to a static structure item. In that case, the content for the static structure item will be deleted, along with any content within that structure item.
 @param success A block object to be executed when `deleteContentForContentID:traverse:success:failure:` succeeds. This block has no return value and takes no arguments.
 @param failure A block object to be executed when `deleteContentForContentID:traverse:success:failure:` fails. This block has no return value and takes one argument: an NSError object describing the error that occurred.
 */
+ (void)deleteContentForContentID:(NSString *)contentID traverse:(BOOL)traverse success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

///-----------------------
/// @name Cache Control
///-----------------------

/**
 Set the TTL in seconds for caching CME content.
 @param timeToLive The specified cache time to live in seconds.
 
 @discussion If there is no network connectivity or the content fails to fetch from CME for another reason the cache will return the last valid piece of content regardless of the TTL.
 */
+ (void)setCacheTTL:(NSTimeInterval)timeToLive;

/**
 The TTL for CME content in seconds. Defaults to 0.
 @return The cached content TTL.
 */
+ (NSTimeInterval)cacheTTL;

/**
 Removes all objects from the cache that have not been used since the specified date.
 @param date Objects that haven't been accessed since this date are removed from the cache.
 */
+ (void)trimCacheToDate:(NSDate *)date;

/**
 Removes all CME data from the cache. This method blocks the calling thread until the cache has been cleared.
 */
+ (void)clearCache;

@end
