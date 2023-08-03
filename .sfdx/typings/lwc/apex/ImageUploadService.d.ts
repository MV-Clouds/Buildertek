declare module "@salesforce/apex/ImageUploadService.postImage" {
  export default function postImage(param: {Image: any, fileType: any}): Promise<any>;
}
declare module "@salesforce/apex/ImageUploadService.getImageResponse" {
  export default function getImageResponse(param: {resultId: any}): Promise<any>;
}
