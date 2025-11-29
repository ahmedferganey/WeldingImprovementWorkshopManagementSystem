from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from .utils import import_excel_to_entries
from .models import WorkshopEntry, Template
from .database import AsyncSessionLocal

scheduler = AsyncIOScheduler()

async def run_import_job(filepath: str, template_id: int):
    async with AsyncSessionLocal() as session:
        tpl = await session.get(Template, template_id)
        if not tpl:
            return
        entries = import_excel_to_entries(filepath, tpl.mapping)
        for data in entries:
            we = WorkshopEntry(template_id=template_id, machine_id=tpl.machine_id, data=data)
            session.add(we)
        await session.commit()

def schedule_daily_import(job_id: str, hour: int, minute: int, filepath: str, template_id: int, db_factory=None):
    trigger = CronTrigger(hour=hour, minute=minute)
    scheduler.add_job(run_import_job, trigger, args=(filepath, template_id), id=job_id, replace_existing=True)

def start_scheduler():
    scheduler.start()
