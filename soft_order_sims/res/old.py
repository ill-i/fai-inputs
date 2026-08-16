from gavo import api
import time

class UWSJobCore(api.UWSJobCore):
    def createJob(self, jobDesc, jobPars, request):
        # Extract parameters
        resource_type = jobPars.get("RESOURCE_TYPE")
        duration = jobPars.get("DURATION")
        priority = jobPars.get("PRIORITY", "normal")

        # Perform validation
        if resource_type not in ["computational", "observational"]:
            raise api.ValidationError(
                what=f"Invalid resource type: {resource_type}", within="RESOURCE_TYPE")
        
        try:
            duration = float(duration)
            if duration <= 0:
                raise ValueError()
        except ValueError:
            raise api.ValidationError(
                what="Duration must be a positive number", within="DURATION")

        # Assign a unique job ID
        job_id = self.getNextJobId()
        jobDesc.jobId = job_id

        # Store job parameters
        jobDesc.parameters = {
            "RESOURCE_TYPE": resource_type,
            "DURATION": duration,
            "PRIORITY": priority
        }

        return jobDesc

    def runJob(self, jobDesc):
        # Retrieve job parameters
        jobPars = jobDesc.parameters
        resource_type = jobPars["RESOURCE_TYPE"]
        duration = jobPars["DURATION"]
        priority = jobPars["PRIORITY"]

        # Simulate resource allocation (replace with real logic)
        # For demonstration, we'll simulate a delay based on priority
        processing_time = 5  # Default processing time in seconds
        if priority == "high":
            processing_time = 2  # Faster processing for high priority

        time.sleep(processing_time)  # Simulate processing time

        # Set job result
        jobDesc.result = f"Allocated {duration} hours of {resource_type} resource with {priority} priority."

    def abortJob(self, jobDesc):
        # Handle job abortion (cleanup if necessary)
        pass

    def getResultTableForJob(self, jobDesc):
        # Return the result as a table
        tableDef = api.TableDef(
            id="orderResult",
            columns=[
                api.Column(name="message", type="text", description="Result message"),
            ]
        )

        rows = [
            {"message": jobDesc.result},
        ]

        return api.TableForDef(tableDef, rows=rows)
